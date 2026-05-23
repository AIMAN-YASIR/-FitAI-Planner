import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user_profile.dart';
import '../models/workout_log.dart';

class AIService {
  static const String apiKey = "your api key here";

  static const String baseUrl = "";

  // ───────────────── DAILY TIP ─────────────────

  Future<String> getDailyTip({
    required String fitnessGoal,
    required int recentWorkoutsCount,
  }) async {
    final prompt = """
Give one short motivational fitness tip.

Fitness Goal: $fitnessGoal
Recent workouts this week: $recentWorkoutsCount

Keep it short and practical.
""";

    return await _sendPrompt(prompt);
  }

  // ───────────────── WORKOUT PLAN ─────────────────

  Future<String> generateWorkoutPlan({
    required String fitnessGoal,
    required int daysPerWeek,
    String? currentFitnessLevel,
  }) async {
    final prompt = """
Create a workout plan.

Goal: $fitnessGoal
Days per week: $daysPerWeek
Fitness level: ${currentFitnessLevel ?? "Beginner"}

Include:
- exercises
- sets
- reps
- rest time
""";

    return await _sendPrompt(prompt);
  }

  // ───────────────── IMPROVEMENT SUGGESTIONS ─────────────────

  Future<String> getImprovementSuggestions({
    required UserProfile profile,
    required List<WorkoutLog> recentLogs,
  }) async {
    final completed = recentLogs.where((e) => e.status == 'completed').length;

    final prompt = """
Give fitness improvement suggestions.

Goal: ${profile.fitnessGoal}
Completed workouts: $completed

Keep suggestions short and useful.
""";

    return await _sendPrompt(prompt);
  }

  // ───────────────── DIET SUGGESTIONS ─────────────────

  Future<String> getDietSuggestions({
    required String fitnessGoal,
    double? weightKg,
  }) async {
    final prompt = """
Give simple diet suggestions.

Goal: $fitnessGoal
Weight: ${weightKg ?? 0} kg

Keep it beginner friendly.
""";

    return await _sendPrompt(prompt);
  }

  // ───────────────── COMMON API METHOD ─────────────────

  Future<String> _sendPrompt(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "openai/gpt-4o-mini",
          "messages": [
            {
              "role": "user",
              "content": prompt,
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data['choices'][0]['message']['content'];
      } else {
        return "AI response failed";
      }
    } catch (e) {
      return "Stay consistent 💪";
    }
  }
}
