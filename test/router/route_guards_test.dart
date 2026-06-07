import 'package:flutter_test/flutter_test.dart';
import 'package:ndt_app/core/router/route_guards.dart';

void main() {
  group('RouteGuards.canAccessAdmin', () {
    test('returns true for admin role', () {
      expect(RouteGuards.canAccessAdmin('admin'), isTrue);
    });

    test('returns false for ndt_company role', () {
      expect(RouteGuards.canAccessAdmin('ndt_company'), isFalse);
    });

    test('returns false for ndt_team role', () {
      expect(RouteGuards.canAccessAdmin('ndt_team'), isFalse);
    });

    test('returns false for null role', () {
      expect(RouteGuards.canAccessAdmin(null), isFalse);
    });

    test('returns false for unknown role', () {
      expect(RouteGuards.canAccessAdmin('unknown'), isFalse);
    });
  });

  group('RouteGuards.canAccessCompany', () {
    test('returns true for admin role', () {
      expect(RouteGuards.canAccessCompany('admin'), isTrue);
    });

    test('returns true for ndt_company role', () {
      expect(RouteGuards.canAccessCompany('ndt_company'), isTrue);
    });

    test('returns false for ndt_team role', () {
      expect(RouteGuards.canAccessCompany('ndt_team'), isFalse);
    });

    test('returns false for null role', () {
      expect(RouteGuards.canAccessCompany(null), isFalse);
    });

    test('returns false for unknown role', () {
      expect(RouteGuards.canAccessCompany('unknown'), isFalse);
    });
  });

  group('RouteGuards.canManageDeployments', () {
    test('returns true for admin role', () {
      expect(RouteGuards.canManageDeployments('admin'), isTrue);
    });

    test('returns true for ndt_company role', () {
      expect(RouteGuards.canManageDeployments('ndt_company'), isTrue);
    });

    test('returns true for ndt_team role', () {
      expect(RouteGuards.canManageDeployments('ndt_team'), isTrue);
    });

    test('returns false for null role', () {
      expect(RouteGuards.canManageDeployments(null), isFalse);
    });

    test('returns true for any non-null role', () {
      expect(RouteGuards.canManageDeployments('custom_role'), isTrue);
    });
  });

  group('RouteGuards.canViewContractors', () {
    test('returns true for admin role', () {
      expect(RouteGuards.canViewContractors('admin'), isTrue);
    });

    test('returns true for ndt_company role', () {
      expect(RouteGuards.canViewContractors('ndt_company'), isTrue);
    });

    test('returns false for ndt_team role', () {
      expect(RouteGuards.canViewContractors('ndt_team'), isFalse);
    });

    test('returns false for null role', () {
      expect(RouteGuards.canViewContractors(null), isFalse);
    });
  });

  group('RouteGuards.canEditContractors', () {
    test('returns true for admin role', () {
      expect(RouteGuards.canEditContractors('admin'), isTrue);
    });

    test('returns true for ndt_company role', () {
      expect(RouteGuards.canEditContractors('ndt_company'), isTrue);
    });

    test('returns false for ndt_team role', () {
      expect(RouteGuards.canEditContractors('ndt_team'), isFalse);
    });
  });

  group('RouteGuards.canViewSummaries', () {
    test('returns true for admin role', () {
      expect(RouteGuards.canViewSummaries('admin'), isTrue);
    });

    test('returns true for ndt_company role', () {
      expect(RouteGuards.canViewSummaries('ndt_company'), isTrue);
    });

    test('returns false for ndt_team role', () {
      expect(RouteGuards.canViewSummaries('ndt_team'), isFalse);
    });
  });
}
