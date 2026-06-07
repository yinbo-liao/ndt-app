import 'package:flutter_test/flutter_test.dart';
import 'package:ndt_app/data/models/joint_detail.dart';

void main() {
  group('JointDetail', () {
    final sampleJson = {
      'joint_no': 'J1',
      'joint_type': 'butt',
      'size': '6"',
      'ndt_method': 'UT',
      'extent': '100%',
      'remarks': 'Line A - Weld Area 3',
    };

    test('fromJson parses all fields correctly', () {
      final joint = JointDetail.fromJson(sampleJson);
      expect(joint.jointNo, 'J1');
      expect(joint.jointType, 'butt');
      expect(joint.size, '6"');
      expect(joint.ndtMethod, 'UT');
      expect(joint.extent, '100%');
      expect(joint.remarks, 'Line A - Weld Area 3');
    });

    test('fromJson handles missing fields with defaults', () {
      final joint = JointDetail.fromJson({});
      expect(joint.jointNo, '');
      expect(joint.jointType, 'butt');
      expect(joint.size, '');
      expect(joint.ndtMethod, 'UT');
      expect(joint.extent, '100%');
      expect(joint.remarks, '');
    });

    test('fromJson handles null fields with defaults', () {
      final json = {
        'joint_no': null,
        'joint_type': null,
        'size': null,
        'ndt_method': null,
        'extent': null,
        'remarks': null,
      };
      final joint = JointDetail.fromJson(json);
      expect(joint.jointNo, '');
      expect(joint.jointType, 'butt');
      expect(joint.size, '');
      expect(joint.ndtMethod, 'UT');
      expect(joint.extent, '100%');
      expect(joint.remarks, '');
    });

    test('jointTypeLabel returns display label for each type', () {
      final types = {
        'butt': 'Butt',
        'fillet': 'Fillet',
        'lap': 'Lap',
        'corner': 'Corner',
        'edge': 'Edge',
        'tee': 'Tee',
        'unknown_type': 'unknown_type',
      };
      for (final entry in types.entries) {
        final joint = JointDetail(
          jointNo: 'J1',
          jointType: entry.key,
          size: '6"',
          ndtMethod: 'UT',
          extent: '100%',
        );
        expect(joint.jointTypeLabel, entry.value,
            reason: 'Failed for type: ${entry.key}');
      }
    });

    test('displayLabel formats correctly', () {
      final joint = JointDetail.fromJson(sampleJson);
      expect(joint.displayLabel, 'J1 — Butt 6" (UT 100%)');
    });

    test('toJson includes all fields', () {
      final joint = JointDetail.fromJson(sampleJson);
      final json = joint.toJson();
      expect(json['joint_no'], 'J1');
      expect(json['joint_type'], 'butt');
      expect(json['size'], '6"');
      expect(json['ndt_method'], 'UT');
      expect(json['extent'], '100%');
      expect(json['remarks'], 'Line A - Weld Area 3');
    });

    test('toJson excludes remarks when empty', () {
      final joint = JointDetail(
        jointNo: 'J1',
        jointType: 'butt',
        size: '6"',
        ndtMethod: 'UT',
        extent: '100%',
      );
      final json = joint.toJson();
      expect(json.containsKey('remarks'), isFalse);
    });

    test('toJson round-trip preserves all fields', () {
      final original = JointDetail.fromJson(sampleJson);
      final json = original.toJson();
      final roundTripped = JointDetail.fromJson(json);
      expect(roundTripped.jointNo, original.jointNo);
      expect(roundTripped.jointType, original.jointType);
      expect(roundTripped.size, original.size);
      expect(roundTripped.ndtMethod, original.ndtMethod);
      expect(roundTripped.extent, original.extent);
      expect(roundTripped.remarks, original.remarks);
    });

    test('copyWith updates specific fields', () {
      final joint = JointDetail.fromJson(sampleJson);
      final copied = joint.copyWith(jointNo: 'J99', jointType: 'fillet');
      expect(copied.jointNo, 'J99');
      expect(copied.jointType, 'fillet');
      expect(copied.size, joint.size); // unchanged
      expect(copied.ndtMethod, joint.ndtMethod); // unchanged
    });

    test('props includes all fields', () {
      final joint = JointDetail.fromJson(sampleJson);
      expect(joint.props.length, 6);
    });

    test('equality works correctly', () {
      final a = JointDetail.fromJson(sampleJson);
      final b = JointDetail.fromJson(sampleJson);
      final c = a.copyWith(jointNo: 'J99');
      expect(a, b);
      expect(a, isNot(c));
    });
  });
}
