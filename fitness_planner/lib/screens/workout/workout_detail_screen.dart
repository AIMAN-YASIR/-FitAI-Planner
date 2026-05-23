// lib/screens/workout/workout_detail_screen.dart
// View routine details and log a workout session

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../models/exercise.dart';
import '../../models/workout_log.dart';
import '../../utils/constrant.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final WorkoutRoutine routine;

  const WorkoutDetailScreen({super.key, required this.routine});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  // Track completed sets/reps for each exercise
  late List<Map<String, int>> _logs;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _logs = widget.routine.exercises.map((ex) => {
      'completedSets': ex.sets,
      'completedReps': ex.reps,
    }).toList();
  }

  Future<void> _saveAsCompleted() async {
    setState(() => _isSaving = true);
    final provider = context.read<AppProvider>();

    final exerciseLogs = widget.routine.exercises.asMap().entries.map((entry) {
      final i = entry.key;
      final ex = entry.value;
      return ExerciseLog(
        exerciseId: ex.exerciseId,
        exerciseName: ex.exerciseName,
        plannedSets: ex.sets,
        plannedReps: ex.reps,
        completedSets: _logs[i]['completedSets']!,
        completedReps: _logs[i]['completedReps']!,
      );
    }).toList();

    final log = WorkoutLog(
      id: '',
      userId: provider.currentUser!.uid,
      routineId: widget.routine.id,
      routineName: widget.routine.name,
      date: DateTime.now(),
      status: WorkoutStatus.completed,
      exerciseLogs: exerciseLogs,
    );

    await provider.addWorkoutLog(log);

    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Workout completed! Great job!'),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _markSkipped() async {
    final provider = context.read<AppProvider>();
    final log = WorkoutLog(
      id: '',
      userId: provider.currentUser!.uid,
      routineId: widget.routine.id,
      routineName: widget.routine.name,
      date: DateTime.now(),
      status: WorkoutStatus.skipped,
      exerciseLogs: [],
    );
    await provider.addWorkoutLog(log);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routine.name),
        actions: [
          TextButton(
            onPressed: _markSkipped,
            child: const Text('Skip', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Routine info header
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, MMMM d').format(DateTime.now()),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.routine.exercises.length} exercises',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.play_circle_filled, color: AppColors.primary, size: 36),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text('Exercise', style: TextStyle(color: AppColors.textSecondary, fontSize: 12))),
                Expanded(child: Text('Sets', style: TextStyle(color: AppColors.textSecondary, fontSize: 12), textAlign: TextAlign.center)),
                Expanded(child: Text('Reps', style: TextStyle(color: AppColors.textSecondary, fontSize: 12), textAlign: TextAlign.center)),
              ],
            ),
          ),
          const Divider(color: AppColors.surfaceLight),

          // Exercise log list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.routine.exercises.length,
              itemBuilder: (context, index) {
                final ex = widget.routine.exercises[index];
                return _ExerciseLogRow(
                  exercise: ex,
                  completedSets: _logs[index]['completedSets']!,
                  completedReps: _logs[index]['completedReps']!,
                  onSetsChanged: (v) => setState(() => _logs[index]['completedSets'] = v),
                  onRepsChanged: (v) => setState(() => _logs[index]['completedReps'] = v),
                );
              },
            ),
          ),

          // Complete button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveAsCompleted,
                icon: _isSaving
                    ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background),
                )
                    : const Icon(Icons.check),
                label: Text(_isSaving ? 'Saving...' : 'Complete Workout'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseLogRow extends StatefulWidget {
  final WorkoutExercise exercise;
  final int completedSets;
  final int completedReps;
  final ValueChanged<int> onSetsChanged;
  final ValueChanged<int> onRepsChanged;

  const _ExerciseLogRow({
    required this.exercise,
    required this.completedSets,
    required this.completedReps,
    required this.onSetsChanged,
    required this.onRepsChanged,
  });

  @override
  State<_ExerciseLogRow> createState() => _ExerciseLogRowState();
}

class _ExerciseLogRowState extends State<_ExerciseLogRow> {
  late TextEditingController _setsCtrl;
  late TextEditingController _repsCtrl;

  @override
  void initState() {
    super.initState();
    _setsCtrl = TextEditingController(text: widget.completedSets.toString());
    _repsCtrl = TextEditingController(text: widget.completedReps.toString());
  }

  @override
  void dispose() {
    _setsCtrl.dispose();
    _repsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.surfaceLight)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.exercise.exerciseName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Plan: ${widget.exercise.sets}×${widget.exercise.reps}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          Expanded(
            child: _SmallNumField(
              controller: _setsCtrl,
              onChanged: (v) => widget.onSetsChanged(int.tryParse(v) ?? widget.completedSets),
            ),
          ),
          Expanded(
            child: _SmallNumField(
              controller: _repsCtrl,
              onChanged: (v) => widget.onRepsChanged(int.tryParse(v) ?? widget.completedReps),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallNumField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SmallNumField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          filled: true,
          fillColor: AppColors.surfaceLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}