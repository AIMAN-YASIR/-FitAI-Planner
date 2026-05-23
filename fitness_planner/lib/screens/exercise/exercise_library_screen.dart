// lib/screens/exercise/exercise_library_screen.dart
// Browse exercises by muscle group / category, search, view details

import 'package:flutter/material.dart';
import '../../utils/constrant.dart';

// ─── DATA MODEL ─────────────────────────────────────────────────────────────

class Exercise {
  final String name;
  final String category;    // e.g. 'Chest', 'Back', 'Legs' …
  final String equipment;   // e.g. 'Barbell', 'Dumbbell', 'Bodyweight' …
  final String difficulty;  // 'Beginner' | 'Intermediate' | 'Advanced'
  final String description;
  final List<String> muscles;
  final IconData icon;

  const Exercise({
    required this.name,
    required this.category,
    required this.equipment,
    required this.difficulty,
    required this.description,
    required this.muscles,
    required this.icon,
  });
}

// ─── STATIC EXERCISE LIST ───────────────────────────────────────────────────

const List<Exercise> _allExercises = [
  // ── Chest ──
  Exercise(
    name: 'Barbell Bench Press',
    category: 'Chest',
    equipment: 'Barbell',
    difficulty: 'Intermediate',
    description:
    'Lie flat on a bench, grip barbell slightly wider than shoulder-width. '
        'Lower the bar to mid-chest under control, then press back up to full '
        'elbow extension without locking out.',
    muscles: ['Pectoralis Major', 'Anterior Deltoid', 'Triceps'],
    icon: Icons.fitness_center,
  ),
  Exercise(
    name: 'Push-Up',
    category: 'Chest',
    equipment: 'Bodyweight',
    difficulty: 'Beginner',
    description:
    'Start in a high plank. Lower your chest to just above the floor '
        'keeping elbows at ~45°, then push back up. Keep core braced throughout.',
    muscles: ['Pectoralis Major', 'Triceps', 'Core'],
    icon: Icons.accessibility_new,
  ),
  Exercise(
    name: 'Dumbbell Fly',
    category: 'Chest',
    equipment: 'Dumbbell',
    difficulty: 'Intermediate',
    description:
    'Lie on a flat bench holding dumbbells above chest, palms facing each '
        'other. With a slight bend in the elbows, arc the weights out and down '
        'until you feel a chest stretch, then bring them back up.',
    muscles: ['Pectoralis Major', 'Anterior Deltoid'],
    icon: Icons.fitness_center,
  ),
  // ── Back ──
  Exercise(
    name: 'Pull-Up',
    category: 'Back',
    equipment: 'Bodyweight',
    difficulty: 'Intermediate',
    description:
    'Hang from a bar with an overhand grip wider than shoulders. Pull your '
        'chest toward the bar by driving elbows down, then lower with control.',
    muscles: ['Latissimus Dorsi', 'Biceps', 'Rear Deltoid'],
    icon: Icons.accessibility_new,
  ),
  Exercise(
    name: 'Barbell Row',
    category: 'Back',
    equipment: 'Barbell',
    difficulty: 'Intermediate',
    description:
    'Hinge at the hips, back flat, bar hanging at arm\'s length. Row the '
        'bar to your lower ribcage, squeezing shoulder blades together, then '
        'lower under control.',
    muscles: ['Latissimus Dorsi', 'Rhomboids', 'Biceps'],
    icon: Icons.fitness_center,
  ),
  Exercise(
    name: 'Lat Pulldown',
    category: 'Back',
    equipment: 'Cable',
    difficulty: 'Beginner',
    description:
    'Sit at a lat pulldown machine, grip the bar wider than shoulders. '
        'Pull the bar to your upper chest, elbows driving toward hips, then '
        'extend arms back up slowly.',
    muscles: ['Latissimus Dorsi', 'Biceps', 'Teres Major'],
    icon: Icons.fitness_center,
  ),
  // ── Legs ──
  Exercise(
    name: 'Barbell Squat',
    category: 'Legs',
    equipment: 'Barbell',
    difficulty: 'Advanced',
    description:
    'Bar rests on upper traps. Brace core, push hips back and knees out as '
        'you descend until thighs are parallel (or below) to the floor, then '
        'drive through heels to stand.',
    muscles: ['Quadriceps', 'Glutes', 'Hamstrings', 'Core'],
    icon: Icons.fitness_center,
  ),
  Exercise(
    name: 'Romanian Deadlift',
    category: 'Legs',
    equipment: 'Barbell',
    difficulty: 'Intermediate',
    description:
    'Hold barbell at hip level, soft bend in knees. Hinge at hips, sliding '
        'bar down thighs until a hamstring stretch is felt, then drive hips '
        'forward to return.',
    muscles: ['Hamstrings', 'Glutes', 'Erector Spinae'],
    icon: Icons.fitness_center,
  ),
  Exercise(
    name: 'Bodyweight Lunge',
    category: 'Legs',
    equipment: 'Bodyweight',
    difficulty: 'Beginner',
    description:
    'Step forward with one foot and lower the back knee toward the floor. '
        'Keep torso upright and front knee behind toes. Push back to starting '
        'position and alternate sides.',
    muscles: ['Quadriceps', 'Glutes', 'Hamstrings'],
    icon: Icons.accessibility_new,
  ),
  // ── Shoulders ──
  Exercise(
    name: 'Overhead Press',
    category: 'Shoulders',
    equipment: 'Barbell',
    difficulty: 'Intermediate',
    description:
    'Standing with barbell at collar-bone height, press straight overhead '
        'until arms are fully extended. Lower under control. Keep core tight '
        'to avoid excessive lumbar arch.',
    muscles: ['Anterior Deltoid', 'Medial Deltoid', 'Triceps'],
    icon: Icons.fitness_center,
  ),
  Exercise(
    name: 'Lateral Raise',
    category: 'Shoulders',
    equipment: 'Dumbbell',
    difficulty: 'Beginner',
    description:
    'Hold dumbbells at sides, slight forward lean. Raise arms out to the '
        'sides to shoulder height with a small bend in the elbows, pause, then '
        'lower slowly.',
    muscles: ['Medial Deltoid'],
    icon: Icons.fitness_center,
  ),
  // ── Arms ──
  Exercise(
    name: 'Barbell Curl',
    category: 'Arms',
    equipment: 'Barbell',
    difficulty: 'Beginner',
    description:
    'Stand holding a barbell with an underhand grip. Keeping elbows pinned '
        'to sides, curl the bar toward your shoulders, then lower with control.',
    muscles: ['Biceps Brachii', 'Brachialis'],
    icon: Icons.fitness_center,
  ),
  Exercise(
    name: 'Tricep Dip',
    category: 'Arms',
    equipment: 'Bodyweight',
    difficulty: 'Intermediate',
    description:
    'Support yourself on parallel bars. Lower your body by bending elbows '
        'to ~90°, keeping torso slightly forward, then press back up to full '
        'elbow extension.',
    muscles: ['Triceps', 'Anterior Deltoid', 'Pectoralis'],
    icon: Icons.accessibility_new,
  ),
  // ── Core ──
  Exercise(
    name: 'Plank',
    category: 'Core',
    equipment: 'Bodyweight',
    difficulty: 'Beginner',
    description:
    'Hold a forearm plank with body in a straight line from head to heels. '
        'Squeeze glutes and brace abs. Avoid letting hips sag or pike up.',
    muscles: ['Rectus Abdominis', 'Transverse Abdominis', 'Glutes'],
    icon: Icons.accessibility_new,
  ),
  Exercise(
    name: 'Cable Crunch',
    category: 'Core',
    equipment: 'Cable',
    difficulty: 'Beginner',
    description:
    'Kneel facing a cable stack with a rope attachment. Holding the rope '
        'behind your head, crunch your elbows toward your knees against the '
        'cable resistance, then extend back up.',
    muscles: ['Rectus Abdominis', 'Obliques'],
    icon: Icons.fitness_center,
  ),
];

// ─── SCREEN ─────────────────────────────────────────────────────────────────

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  String _selectedCategory = 'All';

  static const List<String> _categories = [
    'All', 'Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core',
  ];

  List<Exercise> get _filtered {
    return _allExercises.where((e) {
      final matchCat  = _selectedCategory == 'All' || e.category == _selectedCategory;
      final matchQ    = _query.isEmpty ||
          e.name.toLowerCase().contains(_query.toLowerCase()) ||
          e.muscles.any((m) => m.toLowerCase().contains(_query.toLowerCase()));
      return matchCat && matchQ;
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = _filtered;

    return Scaffold(
      appBar: AppBar(title: const Text('Exercise Library')),
      body: Column(
        children: [
          // ── Search bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search exercises or muscles…',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _query = '');
                  },
                )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceLight,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ── Category chips ──
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final sel = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: sel,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surfaceLight,
                  labelStyle: TextStyle(
                    color: sel ? AppColors.background : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // ── Count ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${exercises.length} exercise${exercises.length == 1 ? '' : 's'}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),

          // ── List ──
          Expanded(
            child: exercises.isEmpty
                ? const Center(
              child: Text(
                'No exercises found.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: exercises.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _ExerciseTile(exercise: exercises[i]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── EXERCISE TILE ───────────────────────────────────────────────────────────

class _ExerciseTile extends StatelessWidget {
  final Exercise exercise;
  const _ExerciseTile({required this.exercise});

  Color get _difficultyColor {
    switch (exercise.difficulty) {
      case 'Beginner':     return const Color(0xFF00E5A0);
      case 'Intermediate': return const Color(0xFF3D8BFF);
      case 'Advanced':     return const Color(0xFFFF5E5E);
      default:             return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(exercise.icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exercise.muscles.join(' · '),
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Badges
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _Badge(label: exercise.category, color: AppColors.primary),
                const SizedBox(height: 4),
                _Badge(label: exercise.difficulty, color: _difficultyColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, ctrl) => _ExerciseDetail(exercise: exercise, scrollController: ctrl),
      ),
    );
  }
}

// ─── EXERCISE DETAIL SHEET ───────────────────────────────────────────────────

class _ExerciseDetail extends StatelessWidget {
  final Exercise exercise;
  final ScrollController scrollController;

  const _ExerciseDetail({required this.exercise, required this.scrollController});

  Color get _difficultyColor {
    switch (exercise.difficulty) {
      case 'Beginner':     return const Color(0xFF00E5A0);
      case 'Intermediate': return const Color(0xFF3D8BFF);
      case 'Advanced':     return const Color(0xFFFF5E5E);
      default:             return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(24),
      children: [
        // Handle
        Center(
          child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Title row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(exercise.icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                exercise.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Badges row
        Wrap(
          spacing: 8,
          children: [
            _Badge(label: exercise.category, color: AppColors.primary),
            _Badge(label: exercise.equipment, color: const Color(0xFF9B6DFF)),
            _Badge(label: exercise.difficulty, color: _difficultyColor),
          ],
        ),
        const SizedBox(height: 20),

        // Description
        const Text(
          'How to perform',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          exercise.description,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.6),
        ),
        const SizedBox(height: 20),

        // Muscles
        const Text(
          'Muscles Worked',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: exercise.muscles.map((m) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(m, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
          )).toList(),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

// ─── BADGE WIDGET ────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}