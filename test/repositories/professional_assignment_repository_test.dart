import 'package:flutter_test/flutter_test.dart';
import 'package:ndt_app/data/models/professional_assignment_model.dart';
import 'package:ndt_app/core/services/supabase_client.dart';

void main() {
  group('ProfessionalAssignmentRepository model parsing', () {
    final sampleJson = {
      'id': 'pa1000000-0000-0000-0000-000000000001',
      'planning_id': 'n1000000-0000-0000-0000-000000000001',
      'professional_id': 'p1000000-0000-0000-0000-000000000001',
      'assigned_role': 'technician',
      'status': 'assigned',
      'assigned_at': '2026-06-01T08:00:00.000Z',
      'created_by': 'u1000000-0000-0000-0000-000000000001',
      'created_at': '2026-06-01T08:00:00.000Z',
      'updated_at': '2026-06-01T08:00:00.000Z',
    };

    test('fromJson parses professional assignment correctly', () {
      final model = ProfessionalAssignmentModel.fromJson(sampleJson);
      expect(model.planningId, 'n1000000-0000-0000-0000-000000000001');
      expect(model.professionalId, 'p1000000-0000-0000-0000-000000000001');
      expect(model.assignedRole, 'technician');
      expect(model.status, 'assigned');
      expect(model.assignedAt, isNotNull);
      expect(model.createdBy, 'u1000000-0000-0000-0000-000000000001');
    });

    test('fromJson applies defaults for missing fields', () {
      final json = {
        'id': 'pa1',
        'planning_id': 'n1',
        'professional_id': 'p1',
      };
      final model = ProfessionalAssignmentModel.fromJson(json);
      expect(model.assignedRole, 'technician');
      expect(model.status, 'assigned');
      expect(model.assignedAt, isNull);
      expect(model.createdBy, isNull);
    });

    test('toJson excludes id when empty', () {
      final model = ProfessionalAssignmentModel(
        id: '',
        planningId: 'n1',
        professionalId: 'p1',
      );
      final json = model.toJson();
      expect(json.containsKey('id'), isFalse);
      expect(json['planning_id'], 'n1');
      expect(json['professional_id'], 'p1');
    });

    test('safeList parses multiple assignments', () {
      final jsonList = [sampleJson, {...sampleJson, 'id': 'pa2', 'status': 'completed'}];
      final safeList = SupabaseClientWrapper.safeList(jsonList);
      final models = safeList
          .map((json) => ProfessionalAssignmentModel.fromJson(json))
          .toList();
      expect(models.length, 2);
      expect(models[0].status, 'assigned');
      expect(models[1].status, 'completed');
    });
  });
}
