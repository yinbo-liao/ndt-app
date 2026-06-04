import 'package:flutter/material.dart';

/// Date picker form field.
///
/// Displays a read-only text field that opens a [showDatePicker]
/// dialog on tap.
class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime?> onChanged;
  final String? Function(DateTime?)? validator;
  final String? hintText;

  const DatePickerField({
    super.key,
    required this.label,
    required this.value,
    this.firstDate,
    this.lastDate,
    required this.onChanged,
    this.validator,
    this.hintText,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: firstDate ?? DateTime(2024),
          lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365)),
          helpText: label,
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: IgnorePointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: label,
            hintText: hintText,
            prefixIcon: const Icon(Icons.calendar_today),
          ),
          controller: TextEditingController(text: _formatDate(value)),
          validator: (_) => validator?.call(value),
        ),
      ),
    );
  }
}
