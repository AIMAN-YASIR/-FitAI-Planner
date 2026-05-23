// lib/screens/workout/workout_list_screen.dart
// Shows all workout routines with ability to create new ones

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/exercise.dart';
import '../../providers/app_provider.dart';
import '../../utils/constrant.dart';
import '../../widgets/common_widgets.dart';
import 'create_routine_screen.dart';
import 'workout_detail_screen.dart';

class WorkoutListScreen extends StatelessWidget {
  const WorkoutListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Workouts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateRoutineScreen()),
            ),
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          if (provider.routines.isEmpty) {
            return EmptyState(
              icon: Icons.fitness_center,
              title: 'No Routines Yet',
              subtitle: 'Create your first workout routine to get started',
              buttonLabel: 'Create Routine',
              onButton: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateRoutineScreen()),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.routines.length,
            itemBuilder: (context, index) {
              final routine = provider.routines[index];
              return _RoutineCard(
                routine: routine,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WorkoutDetailScreen(routine: routine),
                  ),
                ),
                onDelete: () => _confirmDelete(context, provider, routine.id),
                onEdit: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateRoutineScreen(existingRoutine: routine),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateRoutineScreen()),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.add),
        label: const Text('New Routine', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppProvider provider, String routineId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Routine?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              provider.deleteRoutine(routineId);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  final WorkoutRoutine routine;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _RoutineCard({
    required this.routine,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final scheduledDaysText = routine.scheduledDays
        .map((d) => DayNames.short[d])
        .join(', ');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    routine.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  color: AppColors.surfaceLight,
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: AppColors.textPrimary, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: AppColors.error, size: 18),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                  child: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                InfoChip(
                  label: '${routine.exercises.length} exercises',
                  color: const Color(0xFF3D8BFF),
                ),
                const SizedBox(width: 8),
                if (scheduledDaysText.isNotEmpty)
                  InfoChip(label: scheduledDaysText),
              ],
            ),
            if (routine.exercises.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(color: AppColors.surfaceLight),
              const SizedBox(height: 8),
              ...routine.exercises.take(3).map((ex) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.circle, color: AppColors.primary, size: 6),
                    const SizedBox(width: 8),
                    Text(
                      ex.exerciseName,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${ex.sets}×${ex.reps}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )),
              if (routine.exercises.length > 3)
                Text(
                  '+${routine.exercises.length - 3} more exercises',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}