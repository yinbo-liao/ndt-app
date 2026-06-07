import 'package:equatable/equatable.dart';

/// A single joint/weld detail entry within an NDT RFI.
///
/// Stored as a JSONB array element in `project_ndt_planning.joint_details`.
class JointDetail extends Equatable {
  final String jointNo;
  final String jointType; // 'butt','fillet','lap','corner','edge','tee','other'
  final String size; // e.g. "6\"", "10mm"
  final String ndtMethod; // 'UT','MT','PT','RT','VT'
  final String extent; // e.g. "100%", "50%"
  final String remarks; // location or other notes

  const JointDetail({
    required this.jointNo,
    required this.jointType,
    required this.size,
    required this.ndtMethod,
    required this.extent,
    this.remarks = '',
  });

  /// Display label for joint type.
  String get jointTypeLabel {
    switch (jointType) {
      case 'butt':
        return 'Butt';
      case 'fillet':
        return 'Fillet';
      case 'lap':
        return 'Lap';
      case 'corner':
        return 'Corner';
      case 'edge':
        return 'Edge';
      case 'tee':
        return 'Tee';
      default:
        return jointType;
    }
  }

  /// Display label for NDT method.
  String get ndtMethodLabel => ndtMethod;

  /// Shorthand display for list items.
  String get displayLabel => '$jointNo — $jointTypeLabel $size ($ndtMethod $extent)';

  factory JointDetail.fromJson(Map<String, dynamic> json) {
    return JointDetail(
      jointNo: json['joint_no'] as String? ?? '',
      jointType: json['joint_type'] as String? ?? 'butt',
      size: json['size'] as String? ?? '',
      ndtMethod: json['ndt_method'] as String? ?? 'UT',
      extent: json['extent'] as String? ?? '100%',
      remarks: json['remarks'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'joint_no': jointNo,
      'joint_type': jointType,
      'size': size,
      'ndt_method': ndtMethod,
      'extent': extent,
      if (remarks.isNotEmpty) 'remarks': remarks,
    };
  }

  JointDetail copyWith({
    String? jointNo,
    String? jointType,
    String? size,
    String? ndtMethod,
    String? extent,
    String? remarks,
  }) {
    return JointDetail(
      jointNo: jointNo ?? this.jointNo,
      jointType: jointType ?? this.jointType,
      size: size ?? this.size,
      ndtMethod: ndtMethod ?? this.ndtMethod,
      extent: extent ?? this.extent,
      remarks: remarks ?? this.remarks,
    );
  }

  @override
  List<Object?> get props => [
        jointNo,
        jointType,
        size,
        ndtMethod,
        extent,
        remarks,
      ];
}
