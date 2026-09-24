import 'package:flutter/material.dart';

/// Design-system wrapper around Material data tables.
class AppDataTable extends StatelessWidget {
  /// Creates an app data table.
  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.sortColumnIndex,
    this.sortAscending = true,
  });

  /// Table columns.
  final List<DataColumn> columns;

  /// Table rows.
  final List<DataRow> rows;

  /// Sorted column index.
  final int? sortColumnIndex;

  /// Whether sorting is ascending.
  final bool sortAscending;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Data table',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          sortColumnIndex: sortColumnIndex,
          sortAscending: sortAscending,
          columns: columns,
          rows: rows,
        ),
      ),
    );
  }
}
