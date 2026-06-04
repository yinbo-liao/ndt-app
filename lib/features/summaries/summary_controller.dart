import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/summary_model.dart';
import '../../data/repositories/summary_repository.dart';

/// Provides the [SummaryRepository] singleton (unified across features).
final unifiedSummaryRepoProvider =
    Provider<SummaryRepository>((ref) => SummaryRepository());

/// Selected date for summaries.
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// Daily deployment summary for a specific project.
final dailyProjectSummaryProvider = FutureProvider.autoDispose
    .family<DailyProjectSummary?, String>((ref, projectId) async {
  final repository = ref.watch(unifiedSummaryRepoProvider);
  final date = ref.watch(selectedDateProvider);
  return repository.getDailyProjectSummary(
    projectId: projectId,
    date: date,
  );
});

/// Daily deployment summary for a specific company.
final dailyCompanySummaryProvider = FutureProvider.autoDispose
    .family<DailyCompanySummary?, String>((ref, companyId) async {
  final repository = ref.watch(unifiedSummaryRepoProvider);
  final date = ref.watch(selectedDateProvider);
  return repository.getDailyCompanySummary(
    companyId: companyId,
    date: date,
  );
});

/// Parameters for the weekly trend provider.
class WeeklyTrendParams {
  final String projectId;
  final DateTime startDate;
  final DateTime endDate;

  const WeeklyTrendParams({
    required this.projectId,
    required this.startDate,
    required this.endDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyTrendParams &&
          projectId == other.projectId &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode => Object.hash(projectId, startDate, endDate);
}

/// Weekly deployment trend for a project.
final weeklyTrendProvider = FutureProvider.autoDispose
    .family<List<WeeklyTrend>, WeeklyTrendParams>((ref, params) async {
  final repository = ref.watch(unifiedSummaryRepoProvider);
  return repository.getWeeklyTrend(
    projectId: params.projectId,
    startDate: params.startDate,
    endDate: params.endDate,
  );
});

/// Project NDT status summary for a company.
final projectStatusSummaryProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, companyId) async {
  final repository = ref.watch(unifiedSummaryRepoProvider);
  return repository.getProjectStatusSummary(companyId: companyId);
});
