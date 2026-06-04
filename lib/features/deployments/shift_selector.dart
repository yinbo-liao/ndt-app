import 'package:flutter/material.dart';
import '../../data/models/deployment_model.dart';

/// Shift selector widget using Material 3 SegmentedButton.
class ShiftSelectorWidget extends StatelessWidget {
  final ShiftType selectedShift;
  final ValueChanged<ShiftType> onShiftChanged;

  const ShiftSelectorWidget({
    super.key,
    required this.selectedShift,
    required this.onShiftChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shift',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        SegmentedButton<ShiftType>(
          segments: const [
            ButtonSegment(
              value: ShiftType.day,
              label: Text('Day Shift'),
              icon: Icon(Icons.wb_sunny),
            ),
            ButtonSegment(
              value: ShiftType.night,
              label: Text('Night Shift'),
              icon: Icon(Icons.nights_stay),
            ),
          ],
          selected: {selectedShift},
          onSelectionChanged: (Set<ShiftType> newSelection) {
            onShiftChanged(newSelection.first);
          },
        ),
      ],
    );
  }
}
