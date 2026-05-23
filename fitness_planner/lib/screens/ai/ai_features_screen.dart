// lib/screens/ai/ai_features_screen.dart
// All AI-powered features: workout generator, suggestions, tips, diet

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../utils/constrant.dart';
import '../../widgets/common_widgets.dart';

class AiFeaturesScreen extends StatelessWidget {
  const AiFeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Features')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _AiFeatureTile(
            title: 'Smart Workout Generator',
            subtitle: 'Generate a personalized weekly plan',
            icon: Icons.auto_awesome,
            color: Color(0xFF3D8BFF),
            screen: _WorkoutGeneratorSheet(),
          ),
          SizedBox(height: 12),
          _AiFeatureTile(
            title: 'Improvement Suggestions',
            subtitle: 'Get AI feedback on your progress',
            icon: Icons.trending_up,
            color: Color(0xFF00E5A0),
            screen: _ImprovementSheet(),
          ),
          SizedBox(height: 12),
          _AiFeatureTile(
            title: 'Diet Suggestions',
            subtitle: 'Meal ideas aligned to your goal',
            icon: Icons.restaurant_menu_outlined,
            color: Color(0xFFFF9066),
            screen: _DietSheet(),
          ),
        ],
      ),
    );
  }
}

// ─── FEATURE TILE ──────────────────────────────────────────────────────────

class _AiFeatureTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget screen;

  const _AiFeatureTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<AppProvider>(),
          child: DraggableScrollableSheet(
            initialChildSize: 0.9,
            maxChildSize: 0.95,
            minChildSize: 0.5,
            expand: false,
            builder: (_, controller) => screen,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }
}

// ─── WORKOUT GENERATOR SHEET ───────────────────────────────────────────────

class _WorkoutGeneratorSheet extends StatefulWidget {
  const _WorkoutGeneratorSheet();

  @override
  State<_WorkoutGeneratorSheet> createState() => _WorkoutGeneratorSheetState();
}

class _WorkoutGeneratorSheetState extends State<_WorkoutGeneratorSheet> {
  String _selectedGoal     = FitnessGoals.gainMuscle;
  String _selectedLevel    = 'Intermediate';
  int    _daysPerWeek      = 4;
  bool   _generated        = false;

  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return ListView(
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

        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF3D8BFF).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.auto_awesome, color: Color(0xFF3D8BFF)),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'AI Workout Generator',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        if (!_generated || provider.aiWorkoutPlan.isEmpty) ...[
          // Goal selector
          const Text('Fitness Goal', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: FitnessGoals.all.map((g) {
              final sel = _selectedGoal == g;
              return ChoiceChip(
                label: Text(g),
                selected: sel,
                onSelected: (_) => setState(() => _selectedGoal = g),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surfaceLight,
                labelStyle: TextStyle(
                  color: sel ? AppColors.background : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Fitness level
          const Text('Fitness Level', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _levels.map((l) {
              final sel = _selectedLevel == l;
              return ChoiceChip(
                label: Text(l),
                selected: sel,
                onSelected: (_) => setState(() => _selectedLevel = l),
                selectedColor: const Color(0xFF3D8BFF),
                backgroundColor: AppColors.surfaceLight,
                labelStyle: TextStyle(
                  color: sel ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Days per week slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Days Per Week', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_daysPerWeek days',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          Slider(
            value: _daysPerWeek.toDouble(),
            min: 2,
            max: 6,
            divisions: 4,
            activeColor: const Color(0xFF3D8BFF),
            inactiveColor: AppColors.surfaceLight,
            onChanged: (v) => setState(() => _daysPerWeek = v.round()),
          ),
          const SizedBox(height: 24),

          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate Plan'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3D8BFF)),
              onPressed: provider.isAiLoading
                  ? null
                  : () async {
                await provider.generateWorkoutPlan(
                  goal: _selectedGoal,
                  daysPerWeek: _daysPerWeek,
                  fitnessLevel: _selectedLevel,
                );
                setState(() => _generated = true);
              },
            ),
          ),
        ],

        // Loading
        if (provider.isAiLoading) ...[
          const SizedBox(height: 40),
          const Center(child: CircularProgressIndicator(color: Color(0xFF3D8BFF))),
          const SizedBox(height: 12),
          const Center(child: Text('Generating your plan...', style: TextStyle(color: AppColors.textSecondary))),
        ],

        // Error
        if (provider.aiError != null) ...[
          ErrorCard(message: provider.aiError ?? ''),
        ],

        // Result
        if (provider.aiWorkoutPlan.isNotEmpty && !provider.isAiLoading) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: SelectableText(
              provider.aiWorkoutPlan,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.6),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Generate Again'),
            onPressed: () => setState(() {
              _generated = false;
            }),
          ),
        ],
      ],
    );
  }
}

// ─── IMPROVEMENT SUGGESTIONS SHEET ─────────────────────────────────────────

class _ImprovementSheet extends StatefulWidget {
  const _ImprovementSheet();

  @override
  State<_ImprovementSheet> createState() => _ImprovementSheetState();
}

class _ImprovementSheetState extends State<_ImprovementSheet> {
  bool _loaded = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(2)),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.trending_up, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            const Text(
              'Improvement Suggestions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'AI analyzes your recent workout logs to give personalized improvement tips.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 24),

        if (!_loaded)
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.analytics_outlined),
              label: const Text('Analyze My Workouts'),
              onPressed: provider.isAiLoading
                  ? null
                  : () async {
                await provider.getImprovementSuggestions();
                setState(() => _loaded = true);
              },
            ),
          ),

        if (provider.isAiLoading) ...[
          const SizedBox(height: 40),
          const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          const SizedBox(height: 12),
          const Center(child: Text('Analyzing your data...', style: TextStyle(color: AppColors.textSecondary))),
        ],

        if (provider.aiError != null) ...[
          ErrorCard(message: provider.aiError ?? ''),
        ],

        if (provider.aiSuggestions.isNotEmpty && !provider.isAiLoading) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: SelectableText(
              provider.aiSuggestions,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.7),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Suggestions'),
            onPressed: () async {
              await provider.getImprovementSuggestions();
            },
          ),
        ],
      ],
    );
  }
}

// ─── DIET SUGGESTIONS SHEET ────────────────────────────────────────────────

class _DietSheet extends StatefulWidget {
  const _DietSheet();

  @override
  State<_DietSheet> createState() => _DietSheetState();
}

class _DietSheetState extends State<_DietSheet> {
  bool _loaded = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(2)),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9066).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.restaurant_menu_outlined, color: Color(0xFFFF9066)),
            ),
            const SizedBox(width: 12),
            const Text(
              'Diet Suggestions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Meal ideas tailored to your goal: ${provider.userProfile?.fitnessGoal ?? '—'}',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 24),

        if (!_loaded)
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.restaurant_menu_outlined),
              label: const Text('Get Meal Ideas'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF9066)),
              onPressed: provider.isAiLoading
                  ? null
                  : () async {
                await provider.getDietSuggestions();
                setState(() => _loaded = true);
              },
            ),
          ),

        if (provider.isAiLoading) ...[
          const SizedBox(height: 40),
          const Center(child: CircularProgressIndicator(color: Color(0xFFFF9066))),
          const SizedBox(height: 12),
          const Center(child: Text('Getting meal ideas...', style: TextStyle(color: AppColors.textSecondary))),
        ],

        if (provider.aiError != null) ...[
          ErrorCard(message: provider.aiError ?? ''),
        ],

        if (provider.aiDietSuggestions.isNotEmpty && !provider.isAiLoading) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: SelectableText(
              provider.aiDietSuggestions,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.7),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Ideas'),
            onPressed: () async {
              await provider.getDietSuggestions();
            },
          ),
        ],
      ],
    );
  }
}