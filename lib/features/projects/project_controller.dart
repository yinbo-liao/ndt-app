import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/project_model.dart';
import '../../data/repositories/project_repository.dart';

/// Provides the [ProjectRepository] singleton.
final projectRepositoryProvider =
    Provider<ProjectRepository>((ref) => ProjectRepository());

/// Fetch all active projects.
final projectsProvider =
    FutureProvider.autoDispose<List<ProjectModel>>((ref) async {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.getAll();
});

/// Fetch a single project by ID.
final projectDetailProvider = FutureProvider.autoDispose
    .family<ProjectModel?, String>((ref, projectId) async {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.getById(projectId);
});
