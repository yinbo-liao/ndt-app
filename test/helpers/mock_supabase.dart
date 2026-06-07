import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Mock SupabaseClient for testing repositories.
///
/// Use mocktail's when/verify patterns:
/// ```dart
/// final mockClient = MockSupabaseClient();
/// when(() => mockClient.from('table')).thenReturn(mockQuery);
/// ```
class MockSupabaseClient extends Mock implements SupabaseClient {}

/// Mock SupabaseQueryBuilder for testing repository queries.
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

/// Mock PostgrestFilterBuilder for testing filtered queries.
class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder {}

/// Mock PostgrestTransformBuilder for testing transformed queries.
class MockPostgrestTransformBuilder extends Mock
    implements PostgrestTransformBuilder {}

/// Mock GoTrueClient for testing auth operations.
class MockGoTrueClient extends Mock implements GoTrueClient {}

/// Helper to register fallback values for mocktail.
void registerFallbackValues() {
  registerFallbackValue(FakeSupabaseQueryBuilder());
}

class FakeSupabaseQueryBuilder extends Fake implements SupabaseQueryBuilder {}
