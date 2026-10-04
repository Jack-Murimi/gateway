# Architectural & Business Decisions

## 1. Money Representation
- Whole KES integers everywhere (`3300` = KES 3,300).
- No floating-point division or multiplication by 100 for currency amounts.

## 2. Receipt and Invoice Numbers
- Entered manually by staff per sale.
- Unique per branch (`UNIQUE(branch_id, receipt_number)` in `sales`).
- Internal IDs are UUID v4.

## 3. Credit & Cylinder Deposits
- No deposit charged for cylinders left with customer.
- Credit allowed for all registered customers (not walk-in).
- Credit due date defaults to `now + 3 days`. Staff can adjust.
- Null credit limit indicates unconfigured limit (warn, do not block). `0` blocks credit.

## 4. Ledgers as Single Source of Truth
- Stock levels, cylinder counts, customer balances, and supplier balances are derived from append-only movement/ledger tables (`stock_movements`, `cylinder_movements`, `customer_ledger`, `customer_empties_ledger`, `supplier_ledger`).
- No mutable quantity or balance counters as primary source of truth.

## 5. Offline Authentication
- Staff authentication uses local PIN with salt and hashing for convenience while offline.
- Real remote auth and token management will be integrated with Supabase sync in future phases.
