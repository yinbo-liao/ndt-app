import 'package:flutter_test/flutter_test.dart';
import 'package:ndt_app/data/models/project_model.dart';

void main() {
  group('ProjectModel', () {
    final sampleJson = {
      'id': 'p1000000-0000-0000-0000-000000000001',
      'project_name': 'Tuas Mega Port Construction',
      'project_code': 'TMP-2026-01',
      'job_trade': 'Structural Steel',
      'location': 'Tuas, Singapore',
      'client_name': 'Port Authority',
      'classification': 'ABS',
      'qa_incharge_id': 'u1000000-0000-0000-0000-000000000001',
      'ndt_company_id': 'c1000000-0000-0000-0000-000000000001',
      'start_date': '2026-02-01',
      'end_date': '2026-12-31',
      'active': true,
      'created_at': '2026-01-15T08:00:00.000Z',
      'updated_at': '2026-06-01T12:00:00.000Z',
    };

    test('fromJson parses all fields correctly', () {
      final model = ProjectModel.fromJson(sampleJson);

      expect(model.id, 'p1000000-0000-0000-0000-000000000001');
      expect(model.projectName, 'Tuas Mega Port Construction');
      expect(model.projectCode, 'TMP-2026-01');
      expect(model.jobTrade, 'Structural Steel');
      expect(model.location, 'Tuas, Singapore');
      expect(model.clientName, 'Port Authority');
      expect(model.classification, 'ABS');
      expect(model.qaInchargeId, 'u1000000-0000-0000-0000-000000000001');
      expect(model.ndtCompanyId, 'c1000000-0000-0000-0000-000000000001');
      expect(model.startDate, DateTime(2026, 2, 1));
      expect(model.endDate, DateTime(2026, 12, 31));
      expect(model.active, isTrue);
      expect(model.createdAt, isNotNull);
      expect(model.updatedAt, isNotNull);
    });

    test('fromJson handles missing optional fields with defaults', () {
      final minimalJson = {
        'id': 'p-id',
        'project_name': 'Min Project',
        'project_code': 'MIN-001',
        'location': 'Somewhere',
      };
      final model = ProjectModel.fromJson(minimalJson);

      expect(model.jobTrade, isNull);
      expect(model.clientName, isNull);
      expect(model.classification, isNull);
      expect(model.qaInchargeId, isNull);
      expect(model.ndtCompanyId, isNull);
      expect(model.startDate, isNull);
      expect(model.endDate, isNull);
      expect(model.active, isTrue);
      expect(model.createdAt, isNull);
      expect(model.updatedAt, isNull);
    });

    test('fromJson parses date fields only (no time)', () {
      final model = ProjectModel.fromJson(sampleJson);
      expect(model.startDate, DateTime(2026, 2, 1));
      expect(model.startDate!.isUtc, isFalse);
    });

    test('fromJson defaults active to true when null', () {
      final json = Map<String, dynamic>.from(sampleJson)..['active'] = null;
      final model = ProjectModel.fromJson(json);
      expect(model.active, isTrue);
    });

    test('toJson serializes dates as yyyy-MM-dd', () {
      final model = ProjectModel.fromJson(sampleJson);
      final json = model.toJson();

      expect(json['start_date'], '2026-02-01');
      expect(json['end_date'], '2026-12-31');
    });

    test('toJson excludes null optional fields', () {
      final model = ProjectModel(
        id: 'id',
        projectName: 'Name',
        projectCode: 'CODE',
        location: 'Loc',
      );
      final json = model.toJson();

      expect(json.containsKey('job_trade'), isFalse);
      expect(json.containsKey('client_name'), isFalse);
      expect(json.containsKey('classification'), isFalse);
      expect(json.containsKey('start_date'), isFalse);
      expect(json.containsKey('end_date'), isFalse);
    });

    test('toJson excludes id when empty', () {
      final model = ProjectModel(
        id: '',
        projectName: 'Name',
        projectCode: 'CODE',
        location: 'Loc',
      );
      final json = model.toJson();
      expect(json.containsKey('id'), isFalse);
    });

    test('toJson round-trip preserves all fields', () {
      final original = ProjectModel.fromJson(sampleJson);
      final json = original.toJson();
      final roundTripped = ProjectModel.fromJson(json);
      expect(roundTripped, original);
    });

    test('copyWith updates specific fields', () {
      final model = ProjectModel.fromJson(sampleJson);
      final copied = model.copyWith(
        projectName: 'New Project',
        active: false,
      );

      expect(copied.projectName, 'New Project');
      expect(copied.active, isFalse);
      expect(copied.projectCode, model.projectCode); // unchanged
      expect(copied.location, model.location); // unchanged
    });

    test('props includes all fields', () {
      final model = ProjectModel.fromJson(sampleJson);
      expect(model.props.length, 14);
    });

    test('equality works correctly', () {
      final a = ProjectModel.fromJson(sampleJson);
      final b = ProjectModel.fromJson(sampleJson);
      final c = a.copyWith(projectName: 'Different');

      expect(a, b);
      expect(a, isNot(c));
    });
  });
}
