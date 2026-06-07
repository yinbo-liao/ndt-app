import 'package:flutter/material.dart';

/// Date picker form field.
///
/// Displays a read-only text field that opens a [showDatePicker]
/// dialog on tap. Uses a [TextEditingController] to properly
/// reflect programmatic value changes from the parent widget.
class DatePickerField extends StatefulWidget {
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

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  late final TextEditingController _controller;

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatDate(widget.value));
  }

  @override
  void didUpdateWidget(covariant DatePickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.text = _formatDate(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: widget.value ?? DateTime.now(),
          firstDate: widget.firstDate ?? DateTime(2024),
          lastDate:
              widget.lastDate ?? DateTime.now().add(const Duration(days: 365)),
          helpText: widget.label,
        );
        if (picked != null) {
          widget.onChanged(picked);
        }
      },
      child: IgnorePointer(
        child: TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons.calendar_today),
          ),
          validator: (_) => widget.validator?.call(widget.value),
        ),
      ),
    );
  }
}
