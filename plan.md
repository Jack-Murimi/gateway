# GATEWAY POS: Agent Fix & Completion Plan

**Audience:** the coding agent working in `C:\PROJECTS\FLUTTER\gateway_design`
**Goal:** turn the current mock-data UI prototype into a **fully functional, offline-first POS + ERP** with **full CRUD** for products, sales, customers, suppliers, staff and branches, backed by **Drift (SQLite)**, ready for later Supabase sync.

Read this whole file before touching code. Work **phase by phase**, in order. Do not skip the verification gates.

---

## 0. Operating rules

1. **One phase at a time.** At the end of each phase run the gate commands (section 0.2). If any fail, fix them before moving on.
2. **Commit after each phase** with message `phase N: <title>`.
3. **Do not invent business rules.** The rules in section 1 are final. If something is genuinely ambiguous, pick the safest option, write it in `docs/DECISIONS.md`, and continue.
4. **Never leave a feature half-wired.** Every screen you touch must read from and write to the database through a repository. No local `List` state masquerading as data.
5. **Respect the design system** (`lib/design_system`): use tokens and theme extensions, no hardcoded colors, font sizes, paddings or radii in new code. Fix hardcoded values in files you touch.
6. **Update `CLAUDE.md` first (Phase 0).** It currently says "presentation layer only, no repositories, no database access". That is now wrong for this project. Replace that rule with the architecture in section 2.
7. Keep Material 3, Riverpod 3 (code-gen `@riverpod`), go_router, `intl`.

### 0.1 Baseline
Before changes, run and record results in `docs/BASELINE.md`:
```
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

### 0.2 Gate commands (run at the end of every phase)
```
dart run build_runner build --delete-conflicting-outputs
flutter analyze          # must be 0 errors; no new warnings
flutter test             # must be green
```

---

## 1. Fixed business decisions (do not change)

| Topic | Rule |
|---|---|
| Business | Gateway LPG & Accessories, multi-branch retail |
| Branches | Jamhuri, Lavington, Kileleshwa, NextGen (seed these; branches are editable) |
| Roles | `admin`, `director`, `salesperson`, `rider` |
| Money | **Integer whole KES everywhere** (3300 = KES 3,300). Remove every `/ 100` and `* 100`. Update `docs/database_schema.md` accordingly. |
| Receipt / invoice numbers | **Always entered manually.** The app never auto-generates them. Unique per branch. Internal IDs are UUIDs. |
| Cylinder deposit | **No deposit** is charged for cylinders left with a customer. |
| Credit | Allowed for **all registered customers** (not walk-in). **Due date defaults to today + 3 days**, staff can pick another date. Purpose: staff are reminded to call the customer. |
| Sale stages | 1) receipt & sale info, 2) products being sold, 3) rider delivery, 4) return of cylinders, 5) payment |
| Offline | Everything must work with no network. Network is only for future sync. |
| Receipts output | Plain text/clipboard now. PDF and WhatsApp share are **optional, last priority**. |
| Soft deletes | No hard deletes of business records. Use `deleted_at`. |

---

## 2. Target architecture

```
lib/
  app/
    database/                # Drift: tables, AppDatabase, DAOs (move from app/services/database.dart)
    providers/               # keepAlive infra providers (db, prefs, connectivity)
    router/                  # router as a provider, guards from auth state
    shell/
  design_system/             # unchanged structure, cleaned (Phase 9)
  features/<feature>/
    domain/                  # pure Dart models (Equatable)
    data/                    # repository interface + DriftXRepository (delete Mock* when replaced)
    application/             # Riverpod providers (streams) + controllers
    presentation/
  core/
    money.dart               # KES formatting helper (whole shillings)
    ids.dart                 # UUID generator
```

Principles:
- **Repositories are `keepAlive`** and take `AppDatabase`.
- **Reads are streams** (`select(...).watch()`), exposed as `StreamProvider`/`@riverpod Stream<...>`. UI updates automatically after writes. Do **not** rely on `ref.invalidate` as the main refresh mechanism.
- **Every multi-table write is one `db.transaction(...)`** including its sync outbox row.
- **Balances and stock are derived from append-only movement tables** (section 4). Never overwrite a counter.

---

## 3. Phase 0: Prep (30 min)

- [ ] Rewrite `CLAUDE.md` section 2 rule 3 and the "Starting point" notes to match section 2 above. Keep the design-system and accessibility rules.
- [ ] `pubspec.yaml`:
  - add `path` to dependencies (it is imported but undeclared)
  - add `crypto` (PIN hashing)
  - check whether `sqlite3_flutter_libs ^0.6.0+eol` is still correct for the installed Drift/sqlite3 versions per the Drift docs; fix if not
  - dev: add `drift_dev` schema tooling if missing; test imports `package:riverpod/riverpod.dart`; prefer `package:flutter_riverpod/flutter_riverpod.dart` there
  - optional later: `pdf`, `printing`, `share_plus`, `mobile_scanner`
- [ ] Create `docs/DECISIONS.md` and `docs/BASELINE.md`.
- [ ] Create a git branch `offline-first`.

---

## 4. Phase 1: Conventions and cleanup

### 4.1 Money (critical)
- Create `lib/core/money.dart`:
  ```dart
  final _kes = NumberFormat.currency(locale: 'en_KE', symbol: 'KES ', decimalDigits: 0);
  String formatKes(int amount) => _kes.format(amount);
  ```
- Replace all `NumberFormat.simpleCurrency(name: 'KES')` and every `/ 100`, `/ 100.0`, `* 100` in: customers, inventory, reports, receipt_formatter, sales_history, suppliers, report_providers, supplier mock data (`-4500000` becomes `-45000`).
- Fix test expectations if needed (they already assume whole KES).

### 4.2 Shared enums and duplicates
- **One `PaymentMethod`** in `sales/domain/sales_models.dart`: `cash, mpesa, card, bank`. Credit is a **sale status**, not a payment method. Delete the second enum in `payment_dialog.dart`. Remove the `orElse: cash` fallback; card/bank must never become cash.
- **One cart**: keep Riverpod `Cart` (`cart_provider.dart`). Delete `SalesCartController` and its test, or port its tests to `Cart`. Keep one `AddResult`.
- **One `Branch`** (domain). Delete the local `Branch` in `branch_management_screen.dart`. Delete `branch_selection_screen.dart` (hardcoded branches) and `BranchOption` if unused after wiring `BranchSelector`.
- **One `StatusBadge`**: keep `components/status/status_badge.dart`, delete `components/feedback/status_badge.dart`.
- Fix `StatusBadge` colors: `success` must use `AppSemanticColors.success*`, `warning`, `danger`, `info` likewise (not brand-orange `primaryContainer`).

### 4.3 Dead code
- Remove the broken drawer from `AppScaffold` (links `/people`, `/sales-history` do not exist). Navigation is the bottom bar + "More" sheet.
- Remove `AppThemeMode` provider or wire it (Phase 9).

**Gate:** analyze + test green. Search the repo: no `/ 100`, no second `PaymentMethod`, no `SalesCartController`.

---

## 5. Phase 2: Database schema

Location: `lib/app/database/`. If the app has never shipped to a device, edit schema v1 directly. If any device has data, bump `schemaVersion` and write a migration.

### 5.1 Table class naming (avoids clashes with domain classes)
Every table gets a `@DataClassName`:
```dart
@DataClassName('BranchRow')
class Branches extends Table { ... }
// CustomerRow, ProductRow, SaleRow, SaleLineRow, PaymentRow, StaffRow,
// SupplierRow, StockMovementRow, CylinderMovementRow, ...
```

### 5.2 Foreign keys, indexes, pragma
```dart
@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (m) async { await m.createAll(); await _seed(); },
  beforeOpen: (details) async {
    await customStatement('PRAGMA foreign_keys = ON');
  },
);
```
Declare `.references(...)` on FK columns. Create the indexes listed in `docs/database_schema.md` (use `@TableIndex`). Update that doc to match the final schema.

### 5.3 Final tables (v1)

Common columns on mutable master data: `id` (uuid text PK), `created_at`, `updated_at`, `synced_at?`, `deleted_at?`.

**Master data**
- `branches`: id, name, address, phone, is_active
- `staff`: id, name, phone, role, `pin_hash`, `pin_salt`, is_active
- `staff_branches`: staff_id, branch_id (PK both). Admin gets all branches via role, no `'all'` sentinel. Remove the `branch_id='all'` hack.
- `customers`: id, name, credit_limit (int, **nullable = no credit set** → treat as "ask admin", see 8.4), is_active
- `customer_phones`: id, customer_id, phone, is_primary
- `customer_locations`: id, customer_id, address, is_default
- `suppliers`: id, name, phone, email?, last_order_date?
- `products`: id, name, sku?, barcode?, kind (`refill|emptyCylinder|accessory`), price, brand?, size_kg?, min_quantity (default 5), is_active
- Seed a `walk-in` customer row (id `walk-in`) so FKs hold.

**Append-only ledgers (source of truth for quantities and balances)**
- `stock_movements`: id, branch_id, product_id, delta (int, signed), reason (`opening|receive|sale|void_reversal|adjust|transfer_in|transfer_out`), ref_type?, ref_id?, note?, created_by, created_at, synced_at?
- `cylinder_movements`: id, branch_id, brand, size_kg, full_delta, empty_delta, reason (same set + `customer_return`), ref_id?, created_by, created_at, synced_at?
- `customer_ledger`: id, customer_id, branch_id, delta (int, **positive = customer owes us more**), kind (`credit_sale|payment|void_reversal|adjustment`), sale_id?, payment_method?, reference?, created_by, created_at, synced_at?
- `customer_empties_ledger`: id, customer_id, brand, size_kg, delta (int, positive = customer holds more of our empties-owed), sale_id?, created_at, synced_at?
- `supplier_ledger`: id, supplier_id, delta (int, **negative = we owe them**), kind (`purchase|payment|adjustment`), purchase_id?, created_at, synced_at?

Current values are `SUM(delta)`; expose them via DAO queries / Drift views. **Do not store mutable `quantity`, `balance`, `empties_owed` columns.** (If you want a cache for speed, rebuild it from the ledgers, never sync it.)

**Transactions**
- `sales`: id, receipt_number (manual), date (user-selected sale date), branch_id, customer_id, customer_location_id?, status (`draft|completed|credit|voided|cancelled`), cashier_id, `rider_id?`, `delivery_status` (`none|pending|delivered`), `delivered_at?`, due_date?, void_reason?, voided_by?, voided_at?, total (denormalized int), created_at, updated_at, synced_at?, deleted_at?; `UNIQUE(branch_id, receipt_number)`
- `sale_lines`: id, sale_id, product_id, product_name, unit_price, quantity, brand?, size_kg?, kind (snapshot at sale time)
- `payments`: id, sale_id, method, amount, reference?, timestamp. **Unique index on `reference` where method = mpesa** (an M-Pesa code cannot be reused across sales).
- `returned_cylinders`: id, sale_id, brand, size_kg, count
- `purchases`: id, supplier_id, branch_id, reference?, date, total, status (`draft|received|cancelled`)
- `purchase_lines`: id, purchase_id, product_id, quantity, unit_cost
- `stock_transfers`: id, from_branch_id, to_branch_id, status (`sent|received|cancelled`), created_at, received_at?
- `stock_transfer_lines`: id, transfer_id, product_id, quantity
- `sync_queue`: id, entity_table, record_id, operation, payload (JSON), created_at, attempted_at?, attempt_count, error?
- `used_receipts` can be dropped, because the unique constraint on `sales` already blocks reuse (voided sales keep their row).

### 5.4 Seeding (`_seed()` in `onCreate`)
- 4 branches, walk-in customer, the current product catalog from `MockProductRepository`, an `admin` staff with a default PIN **forced to change on first login**, opening stock movements only if requested via a debug flag (do not ship fake stock).

**Gate:** build_runner succeeds; add a Drift in-memory test that opens the DB, runs `_seed`, and checks FK enforcement (insert a sale with a bad `branch_id` must throw).

---

## 6. Phase 3: Repositories and providers

Create Drift implementations and delete the matching `Mock*` classes (keep mocks only under `test/` if a test needs them).

### 6.1 Interfaces to implement
- `ProductRepository`: `watchProducts({includeInactive})`, `getById`, `create`, `update`, `softDelete`, `searchBySkuOrBarcode`
- `StockRepository`: `watchBranchStock(branchId)` (join products + `SUM(delta)`), `currentQty(branchId, productId)`, `receive`, `adjust`, `transfer` (send/receive), all via `stock_movements`; `watchCylinderLedger(branchId)` via `cylinder_movements`
- `CustomerRepository`: CRUD incl. phones/locations; `watchCustomers`, `balanceOf` (SUM), `recordPayment(customerId, amount, method, reference)`, `watchEmptiesOwed`
- `SupplierRepository`: CRUD, `createPurchase`/`receivePurchase` (adds stock movements + supplier ledger), `recordPayment`
- `StaffRepository`: CRUD, `setPin`, `verifyPin`, branch assignment
- `BranchRepository`: CRUD (soft delete; cannot delete a branch with sales, only deactivate)
- `SaleRepository`: `completeSale`, `voidSale`, `watchBranchSales`, `getSale`, `isReceiptNumberUsed`, edit before delivery (see 8.6)

### 6.2 Rules for every write
```dart
Future<void> completeSale(Sale s) => _db.transaction(() async {
  if (await _exists(s.id)) return;                       // idempotent
  if (await isReceiptNumberUsed(s.receiptNumber, s.branchId)) {
    throw ReceiptNumberTaken(s.receiptNumber);
  }
  // 1 validate stock for every line using SUM(delta) (throw InsufficientStock)
  // 2 insert sale, lines, payments, returned_cylinders
  // 3 stock_movements (-qty per line, reason: sale)
  // 4 cylinder_movements (see 8.3)
  // 5 customer_ledger credit_sale (+balance) if status == credit
  // 6 customer_empties_ledger (+refills - returned, per brand/size) for non-walk-in
  // 7 enqueue sync_queue rows (sale aggregate as ONE payload + movement rows)
});
```
- Typed exceptions (`InsufficientStock`, `ReceiptNumberTaken`, `CreditLimitExceeded`), not bare `Exception`. UI maps them to messages.
- Stock may **never** go negative silently. No `.clamp(0, 9999)` anywhere.
- Set `updated_at` in one helper used by every write; do not do it by hand.

### 6.3 Providers
- All repository providers: `@Riverpod(keepAlive: true)`.
- Read providers return `Stream<...>`. Delete the one-shot `FutureProvider`s (`salesList`, `branchInventory`, `customers`, `staffList`, `supplierList` as futures).
- Convert `supplier_providers.dart` to `@riverpod` code-gen like the rest.
- `SalesScreen._loadData` goes away: `watch` products and customers providers.

**Gate:** repository tests against `NativeDatabase.memory()`: create/read/update/soft-delete for each entity; `completeSale` atomicity test (force a failure at step 5 and assert nothing was written); idempotency; receipt uniqueness per branch.

---

## 7. Phase 4: Auth, branch, role

- `authState` / `currentUser` become real `Notifier`s: `login(identifier, pin)`, `logout()`, restore last session from prefs (store only staff id, not the PIN).
- **Offline PIN login:** hash with per-user random salt (`crypto`, SHA-256 over `salt + pin`, repeated, or a proper KDF if available). 5 failed attempts → 60 s lockout. Document that this is local convenience auth and real auth comes with Supabase.
- Login screen: replace Email/Password with Staff (dropdown or phone) + PIN. Update `widget_test.dart` to match.
- `appRouter` becomes a **provider** (`@riverpod GoRouter router(Ref ref)`) using `refreshListenable` bound to auth state, instead of a global using `ProviderScope.containerOf(context)`.
- Guards read `currentUserProvider`. Remove the hardcoded `_currentRole = UserRole.admin` in `AppShell`, so the nav and the router use the same source.
- **Sign Out** must clear auth state, then go to `/login`.
- `userBranches` must filter by `staff_branches` (admin: all).
- `currentBranchProvider` is the single source of branch. Replace `_selectedBranchId = 'jamhuri'` in `SalesScreen` and `SalesHistoryScreen`. Replace `cashierId: 'john_kamau'` with `currentUser.id`.
- Put `BranchSelector` in the shell app bar (visible on every screen, as CLAUDE.md requires). Switching branch with a non-empty cart asks for confirmation (carts are per branch).

---

## 8. Phase 5: Sales flow fixes

### 8.1 Stage flow
Implement the five stages in order. The current code has stages 1, 2, 4, 5.
1. Header (date, **manual** receipt/invoice #, customer, location)
2. Products and cart
3. **Delivery (new):** `delivery_dialog.dart`. Choose "Counter sale (no delivery)" or a rider (staff with role `rider` at this branch). Sets `rider_id` and `delivery_status`. Riders can later mark delivered (see 8.7).
4. Return of cylinders
5. Payment

### 8.2 Returned cylinders
- `CylinderReturn` carries `brand` and `sizeKg` (from the product), not a display string.
- Delete the `brand = cylinderType.split(' ').first` and `sizeKg: 13.0` logic in `sales_screen.dart`.
- Only **refill** lines trigger the return step (not `emptyCylinder`).
- Allow the returned brand/size to differ from the refill sold (customers swap brands). UI: per returned cylinder, pick brand and size, default to the refill's.
- Validation: returned count per refill line cannot exceed sold quantity unless explicitly marked as "extra empties" (decide in DECISIONS.md; default: cap at sold quantity).

### 8.3 Cylinder accounting
- For each **refill** line: `cylinder_movements(full_delta = -qty)` using `line.brand/sizeKg` from the sale line snapshot. Loop over **all** lines. Never parse product ids.
- For each returned cylinder: `cylinder_movements(empty_delta = +count)` for the returned brand/size.
- `customer_empties_ledger`: per brand/size, `+refillsSold(brand,size) - returned(brand,size)` for registered customers. Walk-in is not tracked.
- Void reverses all of the above.
- Decide and document: cylinders are tracked by the **ledger**; `stock_movements` apply to **accessories and empty-cylinder products for sale**. Refill product availability is `cylinder_ledger.full_count` for its brand/size. Make `Cart` stock checks use the right source per `ProductKind`.

### 8.4 Credit
- Default due date `now + 3 days`, date picker allowed. Fix `payment_dialog.dart` (currently 30 days) and any sample data.
- Credit allowed for any registered customer. Credit limit: `null` = no limit configured → **do not block**, but show a warning chip; `0` = credit blocked; `>0` enforced. The limit check is `currentBalance + (total - paidNow) <= limit`.
- Balance sign convention (document in code): `customer_ledger` positive = customer owes us. In UI, customer balance owed shows as **warning/danger**, a credit in the customer's favour shows as success. Fix `_BalanceChip` (currently inverted).

### 8.5 Payment dialog
- **Complete** is enabled only when `remaining <= 0`. If the cashier wants to leave a balance, they must use "Save as credit" (registered customer only), which records partial payments plus credit for the remainder.
- Overpayment: show "Change due" and cap recorded payment at the total (cash only; M-Pesa/bank/card must equal or be less than the remaining).
- M-Pesa code: uppercase, 10 alphanumeric, unique (DB index, plus friendly error).

### 8.6 Void, edit, refunds
- `voidSale(saleId, reason, voidedBy)`, transactional, restores stock, cylinder ledger, customer ledger (`void_reversal`), empties ledger. Only `director`/`admin` (and salesperson only on same-day sales if you decide; default: director/admin).
- Wire `void_sale_dialog.dart` into the sale detail dialog in history.
- Edit: allowed only for `completed|credit` sales not yet voided by **void-and-recreate** (copy the sale into the cart with the same receipt number freed? No: voided sales keep their receipt number). Simplest compliant approach: "Void & re-enter" flow that opens the cart prefilled and requires a **new** manual receipt number. Document it.

### 8.7 Rider delivery
- Rider role sees a "My deliveries" list (sales with `delivery_status = pending` for `rider_id = me`) and can mark **Delivered** (sets `delivered_at`). Admin/director can reassign.

### 8.8 Product search (sales)
- Search by name tokens **and** brand, SKU, barcode. Show stock level next to each result and disable out-of-stock.
- `onSubmitted` adds the top/selected result (mobile keyboard "done" works).
- Barcode: hardware scanners type digits + Enter, so support exact barcode match on submit. Camera scanning via `mobile_scanner` is optional.
- Create the `FocusNode` for `KeyboardListener` in `initState` and dispose it (it is currently created inside `build`).
- Use `Color.withValues` instead of the deprecated `withOpacity`.

**Gate:** tests for: multi-brand refill sale updates each brand's ledger separately; card payment stays `card`; partial payment cannot complete; credit due date default is +3 days; void restores everything; M-Pesa duplicate rejected; receipt number unique per branch.

---

## 9. Phase 6: CRUD screens (the core ask)

Pattern for every entity: **list (search, filters) → detail → create/edit form → soft delete with confirm**. Use `AppDialog` (compact: bottom sheet) or a pushed route for long forms. Validate every field. Show loading, empty, error states. Reads are streams, so lists update automatically.

### 9.1 Products (new screen under Inventory)
- Create/edit: name, kind, brand, size_kg, price, SKU, barcode, min_quantity, active.
- Soft delete (hide from sales; keep on old sale lines).
- Price edits never alter past sale lines (they snapshot price).

### 9.2 Inventory
- Per-branch stock from movements. Use each product's `min_quantity` for low-stock (remove hardcoded 10). Stat chips: "Low" must exclude "Out"; "Total items" should say products, and show units separately.
- Working search field (name, SKU, barcode, brand).
- **Receive stock** (reason `receive`, optional supplier/purchase link).
- **Adjust stock** (signed delta + required reason + note; director/admin).
- **Transfer between branches** (send → receive, with `transfer_out` / `transfer_in` movements and a received confirmation).
- Cylinder ledger view: full/empty per brand/size per branch.
- Remove the "Adjust Stock coming soon" snackbar.

### 9.3 Customers
- Full CRUD including multiple phones and locations, credit limit.
- Detail page: balance owed, empties owed per brand/size, list of credit sales, payment history.
- **Record payment** against balance (cash/M-Pesa/bank, M-Pesa code unique), writes `customer_ledger`.
- **Credit due list**: sales with `status = credit`, ordered by due date, "due today / overdue / upcoming", with tap-to-call (`url_launcher`) so staff can phone the customer. Surface a badge on the Customers tab for items due today or overdue.
- Wire the search field (name/phone).

### 9.4 Suppliers
- Full CRUD, purchase flow (create purchase → receive: adds `stock_movements` + `cylinder_movements` for refills/empties, writes `supplier_ledger`), record supplier payment, balance view ("we owe" vs "they owe").
- Replace the "New Order" stub.

### 9.5 Staff
- Full CRUD, role picker, branch assignment, activate/deactivate, **set/reset PIN**. Replace the do-nothing "Edit Permissions". Only admin can create admin/director; director can manage salesperson/rider.
- Remove the nested `AppScaffold` from `PeopleScreen`.

### 9.6 Branches
- Wire `BranchManagementScreen` to `BranchRepository`. Remove its nested `AppScaffold` (and the `selectedIndex: -1`, which breaks `NavigationBar`).
- Deactivate instead of delete when the branch has history.

### 9.7 Sales history
- Show customer **name** (join), not the id. Search by receipt, customer name, phone, sale id. Filters: date range, status, cashier, rider.
- Detail dialog: lines, payments, returned cylinders, delivery status, void info, **Print/Share receipt**, **Void**.
- Use `branchSalesProvider(currentBranch.id)`.

---

## 10. Phase 7: Reports

- Filter by the sale's **`date`**, not `created_at`. Start-of-day boundaries inclusive (`!isBefore`).
- Implement **Custom range** with `showDateRangePicker`.
- Exclude `voided|cancelled|draft`. Count registered customers distinctly (exclude walk-in from "customers" or label "incl. walk-in").
- Add: sales by branch (existing), sales by product/brand, payment-method breakdown, credit outstanding & aging, cylinder ledger (full/empty/owed by customers), low stock, daily sales chart. Use a lightweight chart (custom painter or `fl_chart`) and respect the design system.
- `startDateProvider` must not go stale after midnight (compute from a clock provider or recompute on resume).
- All reports are DB queries (aggregates in SQL where possible), not full-table loads in Dart.

---

## 11. Phase 8: Offline and sync groundwork

- Every repository write enqueues `sync_queue` rows **inside the same transaction**:
  - sale aggregate (sale + lines + payments + returns) as one JSON payload
  - each ledger/movement row as its own insert
  - master-data upserts/soft-deletes as update rows
- Add a `SyncService` skeleton (no network yet): `pendingCount` stream, `markSynced`, retry/backoff fields. Do **not** call any network API.
- `OfflineBanner`: wording becomes "Working offline • N changes waiting to sync" (driven by `pendingCount`). Show a subtle "All changes synced" or "N pending" status chip in the app bar online and offline. `connectivity_plus` only reports interfaces, not real reachability: note in code that real checks happen at sync time.
- Conflict strategy (document in `docs/SYNC.md`): ledgers are append-only so they merge without conflicts; master data is last-write-wins by `updated_at`; duplicate manual receipt numbers across devices go to a **conflict resolution list** for a director.
- Add a DB backup/export action in Settings (copy the sqlite file to a user-chosen location) as a safety net. This is high value for a shop with one device.
- App must start and work with airplane mode on from a cold start.

---

## 12. Phase 9: Shell, settings, design system cleanup

- **Settings:** persist notification/sound toggles and theme via `PreferencesService`. Wire `ThemeMode` to the saved value (`system|light|dark`). Replace the dark-mode `Switch` with a 3-option selector. Business details (name, address, phone, KRA PIN optional) become editable settings used by receipts (replace the `+254 700 000 000` placeholder). Sign-out works (Phase 4).
- **Shell:** `PopScope` → `onPopInvokedWithResult`; exit the app with `SystemNavigator.pop()` (not `Navigator.pop`). Fix the compact "More" highlight when on `/reports`.
- **Dialogs:** `AppDialog` currently returns a `DraggableScrollableSheet` on compact but is mostly used inside `showDialog`. Add `showAppDialog(context, builder)` which uses `showModalBottomSheet` on compact and `showDialog` otherwise, and use it everywhere. Type `title` as `Widget`.
- **`AppTextField`:** the `validator` param is ignored. Use `TextFormField` and honor it.
- **Hardcoded values:** replace magic numbers (radii 28/16/4, paddings 24/16/12, icon sizes, `fontSize: 12`, elevation) with tokens or theme values in every file you touch. Add missing tokens (`elevation`, dialog radius, etc.).
- Receipt `ReceiptFormatter`: use `formatKes`, include returned cylinders with correct brand/size, delivery/rider if set. Optional last: PDF (`pdf` + `printing`) and WhatsApp (`share_plus`).
- Accessibility: keep 48dp targets (`_QtyButton` is 36dp, so enlarge on touch devices), `Semantics` on new widgets.
- `StatefulShellRoute.indexedStack` with a single branch is fine, but note the nested routes share one navigator. Do not restructure unless needed.

---

## 13. Phase 10: Tests and verification

### 13.1 Automated (must exist and pass)
- Repository tests on in-memory Drift for every repository (CRUD + soft delete + edge cases above).
- `completeSale` atomicity, idempotency, per-branch receipt uniqueness, insufficient stock, credit limit, M-Pesa duplicate.
- `voidSale` full reversal (stock, cylinder ledger, customer balance, empties).
- Ledger invariants: for random sequences of sales/voids/receives, `SUM(delta)` equals expected quantities.
- Cart tests (kept from `cart_provider_test.dart`, updated to Drift/fakes).
- Widget tests: login (PIN), sales happy path (add product, delivery step, payment, success), payment dialog rules, customer form validation.
- Money test: no `/100` regressions (formatting helper with 3300 → `KES 3,300`).
- Drift schema test: migrations (`drift_dev schema` helpers) once you add v2+.

### 13.2 Manual QA script (airplane mode ON from start)
1. Cold start offline. Log in with PIN. Switch branches.
2. Create a product, a customer (2 phones, 2 locations, credit limit), a supplier, a rider.
3. Receive stock via a purchase. Verify inventory and supplier balance.
4. Cash sale of a 13kg refill with a returned empty. Verify stock, cylinder ledger, receipt.
5. Credit sale for the registered customer. Default due date is +3 days. Verify balance and "due" list. Record a payment. Verify balance.
6. Sale with rider delivery; rider marks delivered.
7. Void a sale. Verify full reversal in stock, ledger, balance.
8. Try: duplicate receipt number, duplicate M-Pesa code, oversell, credit for walk-in. Each is rejected with a clear message.
9. Transfer stock between branches and confirm receipt.
10. Kill the app and restart. Everything persisted. Check Reports totals against the sales list.
11. Settings: theme persists; sign out then sign in.

---

## 14. Definition of done

- [ ] No `Mock*Repository` is wired into app providers. Mocks exist only in tests.
- [ ] App works fully offline from a cold start, and all data survives restart.
- [ ] Create/Read/Update/Soft-delete exists in the UI for products, customers, suppliers, staff, branches; sales have create/read/void (and void-and-re-enter).
- [ ] Stock, customer balances, empties owed, supplier balances are derived from ledgers.
- [ ] All multi-table writes are transactional and enqueue sync rows.
- [ ] Money is whole KES everywhere with one formatter.
- [ ] Branch, user and role come from real state. No hardcoded `'jamhuri'` or `'john_kamau'`.
- [ ] Router uses auth state via provider. Sign out works. Role guards match the nav.
- [ ] No nested scaffolds, no dead routes, no duplicate classes listed in section 4.
- [ ] `flutter analyze` clean, `flutter test` green, manual QA script passes.
- [ ] `docs/database_schema.md`, `docs/DECISIONS.md`, `docs/SYNC.md`, and `CLAUDE.md` updated.

## 15. Do-not list

- Do not auto-generate receipt or invoice numbers.
- Do not store mutable balance/quantity counters as the source of truth.
- Do not hard-delete business records.
- Do not add network calls or Supabase code yet.
- Do not silently clamp stock or fall back to cash for unknown payment methods.
- Do not hardcode branch ids, user ids, colors, or sizes.
- Do not leave `ponytail:` markers in code you touched. Resolve them or move them to `docs/DECISIONS.md` with a reason.