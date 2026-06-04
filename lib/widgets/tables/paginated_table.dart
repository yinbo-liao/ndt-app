import 'package:flutter/material.dart';

/// Paginated data table wrapper with per-page controls.
class PaginatedTable extends StatelessWidget {
  final List<String> columns;
  final List<List<Widget>> rows;
  final int rowsPerPage;
  final bool loading;
  final String? emptyMessage;

  const PaginatedTable({
    super.key,
    required this.columns,
    required this.rows,
    this.rowsPerPage = 10,
    this.loading = false,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (rows.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            emptyMessage ?? 'No data available',
            style: TextStyle(color: Colors.grey[500], fontSize: 15),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: PaginatedDataTable(
        columns: columns
            .map((col) => DataColumn(
                  label: Text(
                    col,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ))
            .toList(),
        source: _DataSource(rows: rows),
        rowsPerPage: rowsPerPage,
      ),
    );
  }
}

class _DataSource extends DataTableSource {
  final List<List<Widget>> rows;

  _DataSource({required this.rows});

  @override
  DataRow? getRow(int index) {
    if (index >= rows.length) return null;
    return DataRow(
      cells: rows[index]
          .map((cell) => DataCell(cell))
          .toList(),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => rows.length;

  @override
  int get selectedRowCount => 0;
}
