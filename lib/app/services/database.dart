import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

// Branch table
class Branches extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get address => text()();
  TextColumn get phone => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Staff table
class Staff extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text()();
  TextColumn get role => text()(); // admin/director/salesperson/rider
  TextColumn get branchId => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Customers table
class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text()();
  TextColumn get location => text().nullable()();
  IntColumn get balance => integer().withDefault(const Constant(0))();
  IntColumn get emptiesOwed => integer().withDefault(const Constant(0))();
  IntColumn get creditLimit => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Suppliers table
class Suppliers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text()();
  TextColumn get email => text().nullable()();
  IntColumn get balance => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastOrderDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Products table
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get sku => text().nullable()();
  TextColumn get kind => text()(); // refill/emptyCylinder/accessory
  IntColumn get price => integer()();
  TextColumn get brand => text().nullable()();
  RealColumn get sizeKg => real().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Stock table
class Stock extends Table {
  TextColumn get id => text()();
  TextColumn get branchId => text()();
  TextColumn get productId => text()();
  IntColumn get quantity => integer().withDefault(const Constant(0))();
  IntColumn get minQuantity => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {branchId, productId}
      ];
}

// Cylinder ledger table
class CylinderLedger extends Table {
  TextColumn get id => text()();
  TextColumn get branchId => text()();
  TextColumn get brand => text()();
  RealColumn get sizeKg => real()();
  IntColumn get fullCount => integer().withDefault(const Constant(0))();
  IntColumn get emptyCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {branchId, brand, sizeKg}
      ];
}

// Sales table
class Sales extends Table {
  TextColumn get id => text()();
  TextColumn get receiptNumber => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get branchId => text()();
  TextColumn get customerId => text()();
  TextColumn get customerLocationId => text().nullable()();
  TextColumn get status => text()(); // draft/completed/credit/voided/cancelled
  TextColumn get cashierId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get voidReason => text().nullable()();
  TextColumn get voidedBy => text().nullable()();
  DateTimeColumn get voidedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {branchId, receiptNumber}
      ];
}

// Sale lines table
class SaleLines extends Table {
  TextColumn get id => text()();
  TextColumn get saleId => text()();
  TextColumn get productId => text()();
  TextColumn get productName => text()();
  IntColumn get unitPrice => integer()();
  IntColumn get quantity => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Payments table
class Payments extends Table {
  TextColumn get id => text()();
  TextColumn get saleId => text()();
  TextColumn get method => text()(); // cash/mpesa/bank/credit
  IntColumn get amount => integer()();
  TextColumn get reference => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Returned cylinders table
class ReturnedCylinders extends Table {
  TextColumn get id => text()();
  TextColumn get saleId => text()();
  TextColumn get brand => text()();
  RealColumn get sizeKg => real()();
  IntColumn get count => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Used receipts table
class UsedReceipts extends Table {
  TextColumn get branchId => text()();
  TextColumn get receiptNumber => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {branchId, receiptNumber};
}

// Sync queue table
class SyncQueue extends Table {
  TextColumn get id => text()();
  TextColumn get entityTable => text()();
  TextColumn get recordId => text()();
  TextColumn get operation => text()(); // insert/update/delete
  TextColumn get payload => text()(); // JSON
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get attemptedAt => dateTime().nullable()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  TextColumn get error => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  Branches,
  Staff,
  Customers,
  Suppliers,
  Products,
  Stock,
  CylinderLedger,
  Sales,
  SaleLines,
  Payments,
  ReturnedCylinders,
  UsedReceipts,
  SyncQueue,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Future migrations here
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'gateway_pos.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
