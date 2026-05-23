// lib/screens/exercise/exercise_library_screen.dart
// Browse and manage the exercise library

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/exercise.dart';
import '../../utils/constrant.dart';
import '../../widgets/common_widgets.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  String _search = '';
  String _selectedMuscle = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () => _showAddExerciseDialog(context),
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final muscleGroups = provider.muscleGroups;
          final filtered = provider.exercises.where((e) {
            final matchesMuscle = _selectedMuscle == 'All' || e.muscleGroup == _selectedMuscle;
            final matchesSearch = _search.isEmpty ||
                e.name.toLowerCase().contains(_search.toLowerCase()) ||
                e.muscleGroup.toLowerCase().contains(_search.toLowerCase());
            return matchesMuscle && matchesSearch;
          }).toList();

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TextFormField(
                  onChanged: (v) => setState(() => _search = v),
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search exercises...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    suffixIcon: _search.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                      onPressed: () => setState(() => _search = ''),
                    )
                        : null,
                  ),
                ),
              ),

              // Muscle group filter
              SizedBox(
                height: 52,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: muscleGroups.length,
                  itemBuilder: (context, i) {
                    final muscle = muscleGroups[i];
                    final isSelected = muscle == _selectedMuscle;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMuscle = muscle),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                          ),
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

              // Results count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      '${filtered.length} exercises',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // Exercise list
              Expanded(
                child: filtered.isEmpty
                    ? const EmptyState(
                  icon: Icons.search_off,
                  title: 'No exercises found',
                  subtitle: 'Try a different search or filter',
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _ExerciseCard(exercise: filtered[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddExerciseDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final muscleCtrl = TextEditingController();
    final equipCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Add Custom Exercise', style: TextStyle(color: AppColors.textPrimary)),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  label: 'Exercise Name',
                  controller: nameCtrl,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Muscle Group',
                  hint: 'e.g., Chest, Back, Legs',
                  controller: muscleCtrl,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Equipment',
                  hint: 'e.g., Barbell, Dumbbells, None',
                  controller: equipCtrl,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Description (optional)',
                  controller: descCtrl,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final provider = context.read<AppProvider>();
              await provider.addCustomExercise(Exercise(
                id: '',
                name: nameCtrl.text.trim(),
                muscleGroup: muscleCtrl.text.trim(),
                equipment: equipCtrl.text.trim().isEmpty ? 'None' : equipCtrl.text.trim(),
                description: descCtrl.text.trim(),
                isCustom: true,
                userId: provider.currentUser?.uid,
              ));
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;

  const _ExerciseCard({required this.exercise});

  Color get _muscleColor {
    switch (exercise.muscleGroup) {
      case 'Chest': return const Color(0xFF3D8BFF);
      case 'Back': return const Color(0xFFFF6B6B);
      case 'Legs': return const Color(0xFFFFBD00);
      case 'Shoulders': return const Color(0xFFBF66FF);
      case 'Arms': return AppColors.primary;
      case 'Core': return const Color(0xFFFF9066);
      default: return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _muscleColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                exercise.muscleGroup.substring(0, 1),
                style: TextStyle(
                  color: _muscleColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        exercise.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (exercise.isCustom)
                      const InfoChip(label: 'Custom', color: AppColors.warning),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${exercise.muscleGroup} · ${exercise.equipment}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}