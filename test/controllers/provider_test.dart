import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ndt_app/data/models/contractor_model.dart';
import 'package:ndt_app/data/models/planning_model.dart';
import 'package:ndt_app/data/models/professional_model.dart';
import 'package:ndt_app/data/repositories/contractor_repository.dart';
import 'package:ndt_app/data/repositories/planning_repository.dart';
import 'package:ndt_app/data/repositories/professional_repository.dart';
import 'package:ndt_app/features/contractor_register/contractor_controller.dart';
import 'package:ndt_app/features/ndt_planning/planning_controller.dart';
import 'package:ndt_app/features/professional_register/professional_controller.dart';
import 'package:ndt_app/providers/auth_provider.dart';
import 'package:ndt_app/providers/role_provider.dart';
import 'package:mocktail/mocktail.dart';

// ── Mock Repositories ─────────────────────────────────────────

class MockContractorRepository extends Mock implements ContractorRepository {}
class MockPlanningRepository extends Mock implements PlanningRepository {}
class MockProfessionalRepository extends Mock implements ProfessionalRepository {}

// ── Shared test data ──────────────────────────────────────────

final _sampleContractor = ContractorModel(
  id: 'c1',
  ndtCompanyId: 'comp-1',
  typeOfNdt: 'UT',
  typeOfNdtCertificate: 'UT Level II',
  certificateNo: 'CERT-001',
  issueDate: DateTime(2025, 1, 1),
  expireDate: DateTime(2028, 1, 1),
  reportMonth: DateTime(2026, 6, 1),
);

final _samplePlanning = PlanningModel(
  id: 'n1',
  projectId: 'proj-1',
  ndtCompanyId: 'comp-1',
  ndtCompanyTask: 'Inspection Task',
);

final _sampleProfessional = ProfessionalModel(
  id: 'prof-1',
  name: 'John Smith',
  typeOfCertificate: 'UT',
  issuedDate: DateTime(2025, 1, 1),
  expiryDate: DateTime(2028, 1, 1),
  workingSector: 'marine_section',
  ndtCompanyId: 'comp-1',
);

// ── Helpers ───────────────────────────────────────────────────

/// Creates a [ProviderContainer] with mocked auth state.
ProviderContainer createContainer({
  bool isAdmin = false,
  String? companyId,
  MockContractorRepository? mockContractorRepo,
  MockPlanningRepository? mockPlanningRepo,
  MockProfessionalRepository? mockProfessionalRepo,
}) {
  final overrides = <Override>[];

  // Override auth/role providers
  final role = isAdmin ? 'admin' : 'ndt_company';
  overrides.add(userRoleProvider.overrideWith((ref) => role));
  overrides.add(isAdminProvider.overrideWith((ref) => role == 'admin'));
  overrides.add(currentUserCompanyIdProvider.overrideWith((ref) => companyId));

  // Override repository providers if mocks provided
  if (mockContractorRepo != null) {
    overrides.add(contractorRepositoryProvider.overrideWith((ref) => mockContractorRepo));
  }
  if (mockPlanningRepo != null) {
    overrides.add(planningRepositoryProvider.overrideWith((ref) => mockPlanningRepo));
  }
  if (mockProfessionalRepo != null) {
    overrides.add(professionalRepoProvider.overrideWith((ref) => mockProfessionalRepo));
  }

  return ProviderContainer(overrides: overrides);
}

void main() {
  setUpAll(() {
    registerFallbackValue(_sampleContractor);
    registerFallbackValue(_samplePlanning);
    registerFallbackValue(_sampleProfessional);
  });

  group('Contractor Controller Providers', () {
    test('contractorsProvider — admin uses getAll', () async {
      final mockRepo = MockContractorRepository();
      when(() => mockRepo.getAll()).thenAnswer((_) async => [_sampleContractor]);

      final container = createContainer(
        isAdmin: true,
        mockContractorRepo: mockRepo,
      );

      final result = await container.read(contractorsProvider.future);
      expect(result.length, 1);
      verify(() => mockRepo.getAll()).called(1);
      verifyNever(() => mockRepo.getByCompany(any()));
    });

    test('contractorsProvider — company user uses getByCompany', () async {
      final mockRepo = MockContractorRepository();
      when(() => mockRepo.getByCompany('comp-1'))
          .thenAnswer((_) async => [_sampleContractor]);

      final container = createContainer(
        isAdmin: false,
        companyId: 'comp-1',
        mockContractorRepo: mockRepo,
      );

      final result = await container.read(contractorsProvider.future);
      expect(result.length, 1);
      verify(() => mockRepo.getByCompany('comp-1')).called(1);
      verifyNever(() => mockRepo.getAll());
    });

    test('contractorsProvider — returns empty when companyId is null', () async {
      final mockRepo = MockContractorRepository();

      final container = createContainer(
        isAdmin: false,
        companyId: null,
        mockContractorRepo: mockRepo,
      );

      final result = await container.read(contractorsProvider.future);
      expect(result, isEmpty);
      verifyNever(() => mockRepo.getAll());
      verifyNever(() => mockRepo.getByCompany(any()));
    });
  });

  group('Planning Controller Providers', () {
    test('planningByProjectProvider — with projectId uses getByProject', () async {
      final mockRepo = MockPlanningRepository();
      when(() => mockRepo.getByProject('proj-1'))
          .thenAnswer((_) async => [_samplePlanning]);

      final container = createContainer(mockPlanningRepo: mockRepo);

      final result = await container
          .read(planningByProjectProvider('proj-1').future);
      expect(result.length, 1);
      verify(() => mockRepo.getByProject('proj-1')).called(1);
    });

    test('planningByProjectProvider — empty projectId falls back for admin', () async {
      final mockRepo = MockPlanningRepository();
      when(() => mockRepo.getAll()).thenAnswer((_) async => [_samplePlanning]);

      final container = createContainer(
        isAdmin: true,
        mockPlanningRepo: mockRepo,
      );

      final result = await container
          .read(planningByProjectProvider('').future);
      expect(result.length, 1);
      verify(() => mockRepo.getAll()).called(1);
    });

    test('planningByProjectProvider — empty projectId falls back for company', () async {
      final mockRepo = MockPlanningRepository();
      when(() => mockRepo.getByCompany('comp-1'))
          .thenAnswer((_) async => [_samplePlanning]);

      final container = createContainer(
        isAdmin: false,
        companyId: 'comp-1',
        mockPlanningRepo: mockRepo,
      );

      final result = await container
          .read(planningByProjectProvider('').future);
      expect(result.length, 1);
      verify(() => mockRepo.getByCompany('comp-1')).called(1);
    });

    test('planningByCompanyProvider — admin uses getAll', () async {
      final mockRepo = MockPlanningRepository();
      when(() => mockRepo.getAll()).thenAnswer((_) async => [_samplePlanning]);

      final container = createContainer(
        isAdmin: true,
        mockPlanningRepo: mockRepo,
      );

      final result = await container.read(planningByCompanyProvider.future);
      expect(result.length, 1);
      verify(() => mockRepo.getAll()).called(1);
    });

    test('planningByCompanyProvider — company user uses getByCompany', () async {
      final mockRepo = MockPlanningRepository();
      when(() => mockRepo.getByCompany('comp-1'))
          .thenAnswer((_) async => [_samplePlanning]);

      final container = createContainer(
        isAdmin: false,
        companyId: 'comp-1',
        mockPlanningRepo: mockRepo,
      );

      final result = await container.read(planningByCompanyProvider.future);
      expect(result.length, 1);
      verify(() => mockRepo.getByCompany('comp-1')).called(1);
    });
  });

  group('RFI Count Provider', () {
    test('rfiCountProvider — admin uses getAll count', () async {
      final mockRepo = MockPlanningRepository();
      when(() => mockRepo.getAll()).thenAnswer((_) async => [
            _samplePlanning,
            _samplePlanning.copyWith(id: 'n2'),
          ]);

      final container = createContainer(
        isAdmin: true,
        mockPlanningRepo: mockRepo,
      );

      final result = await container.read(rfiCountProvider.future);
      expect(result, 2);
      verify(() => mockRepo.getAll()).called(1);
      verifyNever(() => mockRepo.getByCompany(any()));
    });

    test('rfiCountProvider — company user uses getByCompany count', () async {
      final mockRepo = MockPlanningRepository();
      when(() => mockRepo.getByCompany('comp-1'))
          .thenAnswer((_) async => [_samplePlanning]);

      final container = createContainer(
        isAdmin: false,
        companyId: 'comp-1',
        mockPlanningRepo: mockRepo,
      );

      final result = await container.read(rfiCountProvider.future);
      expect(result, 1);
      verify(() => mockRepo.getByCompany('comp-1')).called(1);
      verifyNever(() => mockRepo.getAll());
    });

    test('rfiCountProvider — returns 0 when companyId is null', () async {
      final mockRepo = MockPlanningRepository();

      final container = createContainer(
        isAdmin: false,
        companyId: null,
        mockPlanningRepo: mockRepo,
      );

      final result = await container.read(rfiCountProvider.future);
      expect(result, 0);
      verifyNever(() => mockRepo.getAll());
      verifyNever(() => mockRepo.getByCompany(any()));
    });
  });

  group('Professional Controller Providers', () {
    test('professionalsProvider — admin uses getAll', () async {
      final mockRepo = MockProfessionalRepository();
      when(() => mockRepo.getAll()).thenAnswer((_) async => [_sampleProfessional]);

      final container = createContainer(
        isAdmin: true,
        mockProfessionalRepo: mockRepo,
      );

      final result = await container.read(professionalsProvider.future);
      expect(result.length, 1);
      verify(() => mockRepo.getAll()).called(1);
    });

    test('professionalsProvider — company user uses getByCompany', () async {
      final mockRepo = MockProfessionalRepository();
      when(() => mockRepo.getByCompany('comp-1'))
          .thenAnswer((_) async => [_sampleProfessional]);

      final container = createContainer(
        isAdmin: false,
        companyId: 'comp-1',
        mockProfessionalRepo: mockRepo,
      );

      final result = await container.read(professionalsProvider.future);
      expect(result.length, 1);
      verify(() => mockRepo.getByCompany('comp-1')).called(1);
    });

    test('professionalsProvider — returns empty when companyId is null', () async {
      final mockRepo = MockProfessionalRepository();

      final container = createContainer(
        isAdmin: false,
        companyId: null,
        mockProfessionalRepo: mockRepo,
      );

      final result = await container.read(professionalsProvider.future);
      expect(result, isEmpty);
    });
  });

  group('Auth & Role Providers', () {
    test('isAdminProvider returns true for admin role', () {
      final container = createContainer(isAdmin: true);
      expect(container.read(isAdminProvider), isTrue);
    });

    test('isAdminProvider returns false for company user', () {
      final container = createContainer(isAdmin: false);
      expect(container.read(isAdminProvider), isFalse);
    });

    test('currentUserCompanyIdProvider returns companyId when set', () {
      final container = createContainer(companyId: 'comp-1');
      expect(container.read(currentUserCompanyIdProvider), 'comp-1');
    });

    test('currentUserCompanyIdProvider returns null for admin', () {
      final container = createContainer(isAdmin: true, companyId: null);
      expect(container.read(currentUserCompanyIdProvider), isNull);
    });
  });
}
