import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';

/// Provides the [UserRepository] singleton.
final userRepoProvider =
    Provider<UserRepository>((ref) => UserRepository());

/// Fetch all users.
final usersProvider =
    FutureProvider.autoDispose<List<UserModel>>((ref) async {
  final repository = ref.watch(userRepoProvider);
  return repository.getAll();
});
