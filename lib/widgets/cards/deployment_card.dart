import 'package:flutter/material.dart';
import '../../data/models/deployment_model.dart';
import '../../core/theme/color_palette.dart';

/// Card widget for displaying a deployment in a list.
class DeploymentCard extends StatelessWidget {
  final DeploymentModel deployment;
  final String? projectName;
  final VoidCallback? onTap;
  final ValueChanged<String>? onStatusChanged;

  const DeploymentCard({
    super.key,
    required this.deployment,
    this.projectName,
    this.onTap,
    this.onStatusChanged,
  });

  IconData get _shiftIcon =>
      deployment.shift == ShiftType.day
          ? Icons.wb_sunny
          : Icons.nights_stay;

  Color get _shiftColor => ColorPalette.forShift(
        deployment.shift == ShiftType.day ? 'day' : 'night',
      );

  Color get _statusColor =>
      ColorPalette.forTestingStatus(deployment.testingStatus.name);

  String get _statusLabel =>
      deployment.testingStatus.name.snakeToTitleCase;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _shiftColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_shiftIcon, size: 14, color: _shiftColor),
                        const SizedBox(width: 4),
                        Text(
                          deployment.shift == ShiftType.day
                              ? 'Day'
                              : 'Night',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _shiftColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _statusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _statusColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (onStatusChanged != null)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        onStatusChanged?.call(value);
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'completed',
                          child: Text('Mark Completed'),
                        ),
                        const PopupMenuItem(
                          value: 'in_progress',
                          child: Text('Mark In Progress'),
                        ),
                        const PopupMenuItem(
                          value: 'rejected',
                          child: Text('Mark Rejected'),
                        ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Team name and location
              Text(
                deployment.teamDeployment,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              if (projectName != null)
                Text(
                  projectName!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      deployment.jobLocation,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Footer: members and test lengths
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    '${deployment.memberCount} members',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const Spacer(),
                  if (deployment.testLength > 0)
                    Text(
                      'Test: ${deployment.testLength.toStringAsFixed(1)}m',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Extension to convert snake_case enum names to Title Case.
extension _SnakeCaseExtension on String {
  String get snakeToTitleCase {
    return split(RegExp(r'(?=[A-Z])'))
        .map((word) =>
            word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ')
        .trim();
  }
}
