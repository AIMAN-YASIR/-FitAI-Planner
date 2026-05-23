// lib/screens/progress/progress_screen.dart
// Body weight and measurements tracking with fl_chart charts

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../models/workout_log.dart';
import '../../utils/constrant.dart';
import '../../widgets/common_widgets.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Body Stats'),
            Tab(text: 'Workouts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _BodyStatsTab(),
          _WorkoutStatsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProgressDialog(context),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddProgressDialog(BuildContext context) {
    final weightCtrl = TextEditingController();
    final chestCtrl = TextEditingController();
    final waistCtrl = TextEditingController();
    final armsCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          16, 16, 16,
          MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Log Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: AppTextField(label: 'Weight (kg)', controller: weightCtrl, keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: AppTextField(label: 'Arms (cm)', controller: armsCtrl, keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: AppTextField(label: 'Chest (cm)', controller: chestCtrl, keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: AppTextField(label: 'Waist (cm)', controller: waistCtrl, keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final provider = context.read<AppProvider>();
                  await provider.addProgressEntry(ProgressEntry(
                    id: '',
                    userId: provider.currentUser!.uid,
                    date: DateTime.now(),
                    weightKg: double.tryParse(weightCtrl.text),
                    chestCm: double.tryParse(chestCtrl.text),
                    waistCm: double.tryParse(waistCtrl.text),
                    armsCm: double.tryParse(armsCtrl.text),
                  ));
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Save Progress'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── BODY STATS TAB ──────────────────────────────────────────────────────────

class _BodyStatsTab extends StatelessWidget {
  const _BodyStatsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final entries = provider.progressEntries;
        final weightEntries = entries.where((e) => e.weightKg != null).toList();

        if (entries.isEmpty) {
          return const EmptyState(
            icon: Icons.monitor_weight_outlined,
            title: 'No Progress Data',
            subtitle: 'Tap + to log your first body measurements',
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Latest stats
            if (entries.isNotEmpty) ...[
              const Text(
                'Latest Stats',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _LatestStatsRow(entry: entries.last),
              const SizedBox(height: 24),
            ],

            // Weight chart
            if (weightEntries.length >= 2) ...[
              const Text(
                'Weight Over Time',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _WeightChart(entries: weightEntries),
              const SizedBox(height: 24),
            ],

            // Progress history
            const Text(
              'History',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ...entries.reversed.map((entry) => _ProgressEntryRow(
              entry: entry,
              onDelete: () => provider.deleteProgressEntry(entry.id),
            )),
          ],
        );
      },
    );
  }
}

class _LatestStatsRow extends StatelessWidget {
  final ProgressEntry entry;

  const _LatestStatsRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (entry.weightKg != null)
          Expanded(child: StatCard(
            label: 'Weight',
            value: '${entry.weightKg!.toStringAsFixed(1)} kg',
            icon: Icons.monitor_weight_outlined,
          )),
        if (entry.weightKg != null) const SizedBox(width: 10),
        if (entry.chestCm != null)
          Expanded(child: StatCard(
            label: 'Chest',
            value: '${entry.chestCm!.toStringAsFixed(1)} cm',
            icon: Icons.straighten,
            color: const Color(0xFF3D8BFF),
          )),
        if (entry.chestCm != null) const SizedBox(width: 10),
        if (entry.waistCm != null)
          Expanded(child: StatCard(
            label: 'Waist',
            value: '${entry.waistCm!.toStringAsFixed(1)} cm',
            icon: Icons.straighten,
            color: const Color(0xFFFF6B6B),
          )),
      ],
    );
  }
}

class _WeightChart extends StatelessWidget {
  final List<ProgressEntry> entries;

  const _WeightChart({required this.entries});

  @override
  Widget build(BuildContext context) {
    // Take up to last 10 entries
    final data = entries.length > 10 ? entries.sublist(entries.length - 10) : entries;
    final minWeight = data.map((e) => e.weightKg!).reduce((a, b) => a < b ? a : b);
    final maxWeight = data.map((e) => e.weightKg!).reduce((a, b) => a > b ? a : b);
    final padding = maxWeight - minWeight < 2 ? 2.0 : 1.0;

    final spots = data.asMap().entries.map((e) =>
        FlSpot(e.key.toDouble(), e.value.weightKg!),
    ).toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: 5,
            getDrawingHorizontalLine: (_) => const FlLine(
              color: AppColors.surfaceLight,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (v, _) => Text(
                  '${v.toInt()}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final idx = v.toInt();
                  if (idx < 0 || idx >= data.length) return const SizedBox();
                  return Text(
                    DateFormat('M/d').format(data[idx].date),
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minY: minWeight - padding,
          maxY: maxWeight + padding,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 2.5,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressEntryRow extends StatelessWidget {
  final ProgressEntry entry;
  final VoidCallback onDelete;

  const _ProgressEntryRow({required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (entry.weightKg != null) parts.add('${entry.weightKg!.toStringAsFixed(1)} kg');
    if (entry.chestCm != null) parts.add('Chest: ${entry.chestCm!.toStringAsFixed(1)}');
    if (entry.waistCm != null) parts.add('Waist: ${entry.waistCm!.toStringAsFixed(1)}');
    if (entry.armsCm != null) parts.add('Arms: ${entry.armsCm!.toStringAsFixed(1)}');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEE, MMM d yyyy').format(entry.date),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  parts.join(' · '),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 18),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

// ─── WORKOUT STATS TAB ───────────────────────────────────────────────────────

class _WorkoutStatsTab extends StatelessWidget {
  const _WorkoutStatsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final logs = provider.workoutLogs;

        if (logs.isEmpty) {
          return const EmptyState(
            icon: Icons.bar_chart,
            title: 'No Workout Data',
            subtitle: 'Complete some workouts to see stats here',
          );
        }

        final completed = logs.where((l) => l.status == 'completed').length;
        final skipped = logs.where((l) => l.status == 'skipped').length;
        final total = logs.length;

        // Group workouts by week for bar chart
        final weeklyData = _getWeeklyData(logs);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary stats
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Completed',
                    value: '$completed',
                    icon: Icons.check_circle,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Skipped',
                    value: '$skipped',
                    icon: Icons.cancel_outlined,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Rate',
                    value: total > 0 ? '${((completed / total) * 100).round()}%' : '0%',
                    icon: Icons.trending_up,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Weekly bar chart
            if (weeklyData.isNotEmpty) ...[
              const Text(
                'Weekly Workouts (Last 8 Weeks)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _WeeklyBarChart(weeklyData: weeklyData),
              const SizedBox(height: 24),
            ],

            // Recent logs
            const Text(
              'Recent Sessions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ...logs.take(15).map((log) => _WorkoutLogRow(log: log)),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> _getWeeklyData(List<WorkoutLog> logs) {
    final weeks = <String, int>{};
    for (final log in logs) {
      if (log.status != 'completed') continue;
      final weekStart = log.date.subtract(Duration(days: log.date.weekday - 1));
      final key = DateFormat('M/d').format(weekStart);
      weeks[key] = (weeks[key] ?? 0) + 1;
    }

    final sorted = weeks.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return sorted.take(8).map((e) => {'week': e.key, 'count': e.value}).toList();
  }
}

class _WeeklyBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> weeklyData;

  const _WeeklyBarChart({required this.weeklyData});

  @override
  Widget build(BuildContext context) {
    final maxY = weeklyData
        .map((d) => (d['count'] as int).toDouble())
        .reduce((a, b) => a > b ? a : b)
        + 1;

    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxY,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final idx = v.toInt();
                  if (idx < 0 || idx >= weeklyData.length) return const SizedBox();
                  return Text(
                    weeklyData[idx]['week'] as String,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 9),
                  );
                },
              ),
            ),
          ),
          barGroups: weeklyData.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: (e.value['count'] as int).toDouble(),
                  color: AppColors.primary,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY,
                    color: AppColors.surfaceLight,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _WorkoutLogRow extends StatelessWidget {
  final WorkoutLog log;

  const _WorkoutLogRow({required this.log});

  @override
  Widget build(BuildContext context) {
    final isCompleted = log.status == 'completed';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: (isCompleted ? AppColors.primary : AppColors.error).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isCompleted ? Icons.check : Icons.close,
              color: isCompleted ? AppColors.primary : AppColors.error,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.routineName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  DateFormat('EEE, MMM d').format(log.date),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            isCompleted ? 'Done' : 'Skipped',
            style: TextStyle(
              color: isCompleted ? AppColors.primary : AppColors.error,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}