import 'package:flutter/material.dart';

/// A reusable data table widget with configurable columns and rows.
class DataTableWidget extends StatelessWidget {
  final List<String> columns;
  final List<List<Widget>> rows;
  final bool loading;
  final String? emptyMessage;

  const DataTableWidget({
    super.key,
    required this.columns,
    required this.rows,
    this.loading = false,
    this.emptyMessage = 'No data available',
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
            emptyMessage!,
            style: TextStyle(color: Colors.grey[500], fontSize: 15),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: columns
            .map((col) => DataColumn(
                  label: Text(
                    col,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ))
            .toList(),
        rows: rows.map((row) {
          return DataRow(
            cells: row
                .map((cell) => DataCell(cell))
                .toList(),
          );
        }).toList(),
      ),
    );
  }
}
