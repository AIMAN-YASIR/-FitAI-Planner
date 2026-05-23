// lib/screens/workout/create_routine_screen.dart
// Create or edit a workout routine with exercises, sets, reps, days

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/app_provider.dart';
import '../../models/exercise.dart';
import '../../utils/constrant.dart';
import '../../widgets/common_widgets.dart';

class CreateRoutineScreen extends StatefulWidget {
  final WorkoutRoutine? existingRoutine;

  const CreateRoutineScreen({super.key, this.existingRoutine});

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  List<int> _selectedDays = [];
  List<WorkoutExercise> _exercises = [];

  @override
  void initState() {
    super.initState();
    if (widget.existingRoutine != null) {
      _nameCtrl.text = widget.existingRoutine!.name;
      _selectedDays = List.from(widget.existingRoutine!.scheduledDays);
      _exercises = List.from(widget.existingRoutine!.exercises);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one exercise'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final provider = context.read<AppProvider>();
    final routine = WorkoutRoutine(
      id: widget.existingRoutine?.id ?? '',
      userId: provider.currentUser!.uid,
      name: _nameCtrl.text.trim(),
      scheduledDays: _selectedDays,
      exercises: _exercises,
      createdAt: widget.existingRoutine?.createdAt ?? DateTime.now(),
    );

    if (widget.existingRoutine != null) {
      await provider.updateRoutine(routine);
    } else {
      await provider.addRoutine(routine);
    }

    if (mounted) Navigator.pop(context);
  }

  void _addExercise() async {
    final provider = context.read<AppProvider>();
    final result = await showModalBottomSheet<Exercise>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ExercisePicker(exercises: provider.exercises),
    );

    if (result != null) {
      setState(() {
        _exercises.add(WorkoutExercise(
          exerciseId: result.id,
          exerciseName: result.name,
          sets: 3,
          reps: 10,
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingRoutine != null ? 'Edit Routine' : 'New Routine'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Routine name
            AppTextField(
              label: 'Routine Name',
              hint: 'e.g., Chest Day, Leg Day',
              controller: _nameCtrl,
              validator: (v) => v == null || v.isEmpty ? 'Enter a routine name' : null,
            ),
            const SizedBox(height: 24),

            // Day selector
            const Text(
              'Schedule Days',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(7, (index) {
                final isSelected = _selectedDays.contains(index);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      if (isSelected) {
                        _selectedDays.remove(index);
                      } else {
                        _selectedDays.add(index);
                      }
                    }),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                        ),
                      ),
                      child: Text(
                        DayNames.short[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.background : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Exercises
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Exercises',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _addExercise,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_exercises.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceLight, style: BorderStyle.solid),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.add_circle_outline, color: AppColors.textSecondary, size: 32),
                    SizedBox(height: 8),
                    Text('No exercises added yet', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),

            ..._exercises.asMap().entries.map((entry) {
              final index = entry.key;
              final ex = entry.value;
              return _ExerciseItem(
                exercise: ex,
                onUpdate: (updated) => setState(() => _exercises[index] = updated),
                onRemove: () => setState(() => _exercises.removeAt(index)),
              );
            }),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              child: Text(widget.existingRoutine != null ? 'Update Routine' : 'Save Routine'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// Exercise item in routine editor
class _ExerciseItem extends StatefulWidget {
  final WorkoutExercise exercise;
  final ValueChanged<WorkoutExercise> onUpdate;
  final VoidCallback onRemove;

  const _ExerciseItem({
    required this.exercise,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  State<_ExerciseItem> createState() => _ExerciseItemState();
}

class _ExerciseItemState extends State<_ExerciseItem> {
  late TextEditingController _setsCtrl;
  late TextEditingController _repsCtrl;

  @override
  void initState() {
    super.initState();
    _setsCtrl = TextEditingController(text: widget.exercise.sets.toString());
    _repsCtrl = TextEditingController(text: widget.exercise.reps.toString());
  }

  @override
  void dispose() {
    _setsCtrl.dispose();
    _repsCtrl.dispose();
    super.dispose();
  }

  void _update() {
    widget.onUpdate(widget.exercise.copyWith(
      sets: int.tryParse(_setsCtrl.text) ?? widget.exercise.sets,
      reps: int.tryParse(_repsCtrl.text) ?? widget.exercise.reps,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.exercise.exerciseName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.error, size: 18),
                onPressed: widget.onRemove,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _NumInput(label: 'Sets', controller: _setsCtrl, onChanged: (_) => _update()),
              const SizedBox(width: 12),
              _NumInput(label: 'Reps', controller: _repsCtrl, onChanged: (_) => _update()),
            ],
          ),
        ],
      ),
    );
  }
}

class _NumInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _NumInput({
    required this.label,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            onChanged: onChanged,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: AppColors.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Exercise picker bottom sheet
class _ExercisePicker extends StatefulWidget {
  final List<Exercise> exercises;

  const _ExercisePicker({required this.exercises});

  @override
  State<_ExercisePicker> createState() => _ExercisePickerState();
}

class _ExercisePickerState extends State<_ExercisePicker> {
  String _search = '';
  String _selectedMuscle = 'All';

  List<String> get _muscleGroups {
    final groups = widget.exercises.map((e) => e.muscleGroup).toSet().toList();
    groups.sort();
    return ['All', ...groups];
  }

  List<Exercise> get _filtered {
    return widget.exercises.where((e) {
      final matchesMuscle = _selectedMuscle == 'All' || e.muscleGroup == _selectedMuscle;
      final matchesSearch = _search.isEmpty ||
          e.name.toLowerCase().contains(_search.toLowerCase());
      return matchesMuscle && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Select Exercise',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextFormField(
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Muscle filter
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _muscleGroups.length,
              itemBuilder: (context, i) {
                final muscle = _muscleGroups[i];
                final isSelected = muscle == _selectedMuscle;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMuscle = muscle),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      muscle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.background : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Exercise list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final ex = _filtered[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                  title: Text(
                    ex.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${ex.muscleGroup} · ${ex.equipment}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  trailing: const Icon(Icons.add_circle, color: AppColors.primary),
                  onTap: () => Navigator.pop(context, ex),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}