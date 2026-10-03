# Offline-First Database Schema

Gateway POS local SQLite schema for offline-first operation with eventual Supabase sync.

## Design Principles
1. **Offline-first**: All operations work without network
2. **UUID primary keys**: Compatible with distributed sync (no auto-increment)
3. **Sync metadata**: `synced_at`, `updated_at` timestamps on all tables
4. **Soft deletes**: `deleted_at` for sync reconciliation
5. **Branch isolation**: All transactional data has `branch_id`

## Core Tables

### branches
```sql
CREATE TABLE branches (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  address TEXT NOT NULL,
  phone TEXT NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  synced_at TEXT,
  deleted_at TEXT
);
```

### staff
```sql
CREATE TABLE staff (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  role TEXT NOT NULL, -- admin/director/salesperson/rider
  branch_id TEXT NOT NULL, -- 'all' for admin
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  synced_at TEXT,
  deleted_at TEXT,
  FOREIGN KEY (branch_id) REFERENCES branches(id)
);
```

### customers
```sql
CREATE TABLE customers (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  location TEXT,
  balance INTEGER NOT NULL DEFAULT 0, -- KES minor units (cents)
  empties_owed INTEGER NOT NULL DEFAULT 0,
  credit_limit INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  synced_at TEXT,
  deleted_at TEXT
);
```

### suppliers
```sql
CREATE TABLE suppliers (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  email TEXT,
  balance INTEGER NOT NULL DEFAULT 0, -- negative = we owe them
  last_order_date TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  synced_at TEXT,
  deleted_at TEXT
);
```

### products
```sql
CREATE TABLE products (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  sku TEXT,
  kind TEXT NOT NULL, -- refill/emptyCylinder/accessory
  price INTEGER NOT NULL, -- KES minor units
  brand TEXT,
  size_kg REAL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  synced_at TEXT,
  deleted_at TEXT
);
```

### stock
```sql
CREATE TABLE stock (
  id TEXT PRIMARY KEY,
  branch_id TEXT NOT NULL,
  product_id TEXT NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 0,
  min_quantity INTEGER NOT NULL DEFAULT 0,
  updated_at TEXT NOT NULL,
  synced_at TEXT,
  FOREIGN KEY (branch_id) REFERENCES branches(id),
  FOREIGN KEY (product_id) REFERENCES products(id),
  UNIQUE(branch_id, product_id)
);
```

### cylinder_ledger
```sql
CREATE TABLE cylinder_ledger (
  id TEXT PRIMARY KEY,
  branch_id TEXT NOT NULL,
  brand TEXT NOT NULL,
  size_kg REAL NOT NULL,
  full_count INTEGER NOT NULL DEFAULT 0,
  empty_count INTEGER NOT NULL DEFAULT 0,
  updated_at TEXT NOT NULL,
  synced_at TEXT,
  FOREIGN KEY (branch_id) REFERENCES branches(id),
  UNIQUE(branch_id, brand, size_kg)
);
```

### sales
```sql
CREATE TABLE sales (
  id TEXT PRIMARY KEY,
  receipt_number TEXT NOT NULL,
  date TEXT NOT NULL,
  branch_id TEXT NOT NULL,
  customer_id TEXT NOT NULL,
  customer_location_id TEXT,
  status TEXT NOT NULL, -- draft/completed/credit/voided/cancelled
  cashier_id TEXT NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  synced_at TEXT,
  due_date TEXT,
  void_reason TEXT,
  voided_by TEXT,
  voided_at TEXT,
  deleted_at TEXT,
  FOREIGN KEY (branch_id) REFERENCES branches(id),
  FOREIGN KEY (customer_id) REFERENCES customers(id),
  FOREIGN KEY (cashier_id) REFERENCES staff(id),
  UNIQUE(branch_id, receipt_number)
);
```

### sale_lines
```sql
CREATE TABLE sale_lines (
  id TEXT PRIMARY KEY,
  sale_id TEXT NOT NULL,
  product_id TEXT NOT NULL,
  product_name TEXT NOT NULL, -- denormalized for receipt display
  unit_price INTEGER NOT NULL,
  quantity INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id)
);
```

### payments
```sql
CREATE TABLE payments (
  id TEXT PRIMARY KEY,
  sale_id TEXT NOT NULL,
  method TEXT NOT NULL, -- cash/mpesa/bank/credit
  amount INTEGER NOT NULL,
  reference TEXT,
  timestamp TEXT NOT NULL,
  created_at TEXT NOT NULL,
  FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE
);
```

### returned_cylinders
```sql
CREATE TABLE returned_cylinders (
  id TEXT PRIMARY KEY,
  sale_id TEXT NOT NULL,
  brand TEXT NOT NULL,
  size_kg REAL NOT NULL,
  count INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE
);
```

### sync_queue
Outbox pattern for pending sync operations.
```sql
CREATE TABLE sync_queue (
  id TEXT PRIMARY KEY,
  table_name TEXT NOT NULL,
  record_id TEXT NOT NULL,
  operation TEXT NOT NULL, -- insert/update/delete
  payload TEXT NOT NULL, -- JSON
  created_at TEXT NOT NULL,
  attempted_at TEXT,
  attempt_count INTEGER NOT NULL DEFAULT 0,
  error TEXT
);
CREATE INDEX idx_sync_queue_pending ON sync_queue(attempted_at, attempt_count);
```

### used_receipts
Track used receipt numbers per branch (prevent reuse after voiding).
```sql
CREATE TABLE used_receipts (
  branch_id TEXT NOT NULL,
  receipt_number TEXT NOT NULL,
  created_at TEXT NOT NULL,
  PRIMARY KEY (branch_id, receipt_number),
  FOREIGN KEY (branch_id) REFERENCES branches(id)
);
```

## Indexes
```sql
CREATE INDEX idx_sales_branch_date ON sales(branch_id, date DESC);
CREATE INDEX idx_sales_customer ON sales(customer_id);
CREATE INDEX idx_sales_status ON sales(status);
CREATE INDEX idx_stock_branch ON stock(branch_id);
CREATE INDEX idx_staff_branch ON staff(branch_id);
CREATE INDEX idx_sync_metadata ON sales(synced_at, updated_at);
```

## Migration Strategy
- Version 1: Core tables (branches, staff, customers, products, stock, sales, payments)
- Version 2: Cylinder ledger + returned cylinders
- Version 3: Suppliers + sync queue

## Sync Strategy (future Supabase integration)
1. Local writes go to SQLite immediately
2. Record added to `sync_queue` with payload
3. Background worker attempts sync when online
4. On success: update `synced_at`, remove from queue
5. On conflict: last-write-wins or manual resolution UI
6. Periodic pull: fetch `updated_at > last_synced_at` from server
