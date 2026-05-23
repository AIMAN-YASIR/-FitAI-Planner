// lib/utils/constants.dart

import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF00E5A0);
  static const Color primaryDark = Color(0xFF00B87A);
  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF151C2E);
  static const Color surfaceLight = Color(0xFF1E2840);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A95AA);
  static const Color error = Color(0xFFFF4757);
  static const Color warning = Color(0xFFFFBD00);
  static const Color success = Color(0xFF00E5A0);
  static const Color chartBlue = Color(0xFF3D8BFF);
  static const Color chartRed = Color(0xFFFF6B6B);
  static const Color chartPurple = Color(0xFFBF66FF);
  static const Color chartOrange = Color(0xFFFF9066);
}

class AppStrings {
  static const String appName = 'FitAI Planner';
  static const String openRouterBaseUrl = '';
  // Replace with your actual OpenRouter API key from https://openrouter.ai
  static const String openRouterApiKey = 'YOUR_OPENROUTER_API_KEY_HERE';
  static const String openRouterModel = 'openai/gpt-4o-mini';
}

class FitnessGoals {
  static const String loseWeight = 'Lose Weight';
  static const String gainMuscle = 'Gain Muscle';
  static const String maintain = 'Maintain';
  static const List<String> all = [loseWeight, gainMuscle, maintain];
}

class WorkoutStatus {
  static const String planned = 'planned';
  static const String completed = 'completed';
  static const String skipped = 'skipped';
}

class DayNames {
  static const List<String> short = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];
  static const List<String> full = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
}
