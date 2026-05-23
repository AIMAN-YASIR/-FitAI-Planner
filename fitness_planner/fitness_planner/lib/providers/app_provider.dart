// lib/providers/app_provider.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';
import '../models/exercise.dart';
import '../models/workout_log.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/ai_service.dart';

class AppProvider extends ChangeNotifier {

  // ───────────────── SERVICES ─────────────────

  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final AIService _aiService = AIService();

  // ───────────────── STATE ─────────────────

  User? _currentUser;
  UserProfile? _userProfile;

  List<WorkoutRoutine> _routines = [];
  List<Exercise> _exercises = [];
  List<WorkoutLog> _workoutLogs = [];
  List<ProgressEntry> _progressEntries = [];

  String _dailyTip = '';

  bool _isLoading = false;
  String? _error;

  // AI
  String _aiWorkoutPlan = '';
  String _aiSuggestions = '';
  String _aiDietSuggestions = '';

  bool _isAiLoading = false;
  String? _aiError;

  // ───────────────── GETTERS ─────────────────

  User? get currentUser => _currentUser;

  UserProfile? get userProfile => _userProfile;

  List<WorkoutRoutine> get routines => _routines;

  List<Exercise> get exercises => _exercises;

  List<WorkoutLog> get workoutLogs => _workoutLogs;

  List<ProgressEntry> get progressEntries => _progressEntries;

  String get dailyTip => _dailyTip;

  bool get isLoading => _isLoading;

  String? get error => _error;

  String get aiWorkoutPlan => _aiWorkoutPlan;

  String get aiSuggestions => _aiSuggestions;

  String get aiDietSuggestions => _aiDietSuggestions;

  bool get isAiLoading => _isAiLoading;

  String? get aiError => _aiError;

  bool get isAuthenticated => _currentUser != null;

  // ───────────────── AUTH ─────────────────

  void setUser(User? user) {

    _currentUser = user;

    if (user != null) {
      _loadUserData();
    } else {
      _clearData();
    }

    notifyListeners();
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String fitnessGoal,
    double? heightCm,
    double? weightKg,
  }) async {

    _setLoading(true);

    try {

      _userProfile = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        fitnessGoal: fitnessGoal,
        heightCm: heightCm,
        weightKg: weightKg,
      );

    } catch (e) {

      _setError(e.toString());

    } finally {

      _setLoading(false);
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {

    _setLoading(true);

    try {

      await _authService.signIn(
        email: email,
        password: password,
      );

    } catch (e) {

      _setError(e.toString());

    } finally {

      _setLoading(false);
    }
  }

  Future<void> signOut() async {

    await _authService.signOut();

    _clearData();

    notifyListeners();
  }

  // ───────────────── LOAD USER DATA ─────────────────

  Future<void> _loadUserData() async {

    if (_currentUser == null) return;

    _setLoading(true);

    try {

      await _firestoreService.seedBuiltInExercises();

      final results = await Future.wait([

        _firestoreService.getUserProfile(_currentUser!.uid),

        _firestoreService.getExercises(_currentUser!.uid),

        _firestoreService.getUserRoutines(_currentUser!.uid),

        _firestoreService.getUserLogs(_currentUser!.uid),

        _firestoreService.getProgressEntries(_currentUser!.uid),

      ]);

      _userProfile = results[0] as UserProfile?;

      _exercises = results[1] as List<Exercise>;

      _routines = results[2] as List<WorkoutRoutine>;

      _workoutLogs = results[3] as List<WorkoutLog>;

      _progressEntries = results[4] as List<ProgressEntry>;

      await _loadDailyTip();

    } catch (e) {

      _setError("Failed to load data: $e");

    } finally {

      _setLoading(false);
    }
  }

  Future<void> refreshData() async {

    await _loadUserData();
  }

  void _clearData() {

    _userProfile = null;

    _routines = [];

    _exercises = [];

    _workoutLogs = [];

    _progressEntries = [];

    _dailyTip = '';

    _aiWorkoutPlan = '';

    _aiSuggestions = '';

    _aiDietSuggestions = '';
  }

  // ───────────────── PROFILE ─────────────────

  Future<void> updateProfile(UserProfile profile) async {

    try {

      await _firestoreService.updateUserProfile(profile);

      _userProfile = profile;

      notifyListeners();

    } catch (e) {

      _setError("Failed to update profile");
    }
  }

  // ───────────────── EXERCISES ─────────────────

  Future<void> addCustomExercise(Exercise exercise) async {

    try {

      final id = await _firestoreService.addExercise(exercise);

      _exercises.add(
        Exercise(
          id: id,
          name: exercise.name,
          muscleGroup: exercise.muscleGroup,
          equipment: exercise.equipment,
          description: exercise.description,
          isCustom: true,
          userId: _currentUser?.uid,
        ),
      );

      notifyListeners();

    } catch (e) {

      _setError("Failed to add exercise");
    }
  }

  List<Exercise> getExercisesByMuscle(String muscleGroup) {

    if (muscleGroup == 'All') {
      return _exercises;
    }

    return _exercises
        .where((e) => e.muscleGroup == muscleGroup)
        .toList();
  }

  List<String> get muscleGroups {

    final groups =
    _exercises.map((e) => e.muscleGroup).toSet().toList();

    groups.sort();

    return ['All', ...groups];
  }

  // ───────────────── ROUTINES ─────────────────

  Future<void> addRoutine(WorkoutRoutine routine) async {

    try {

      final id = await _firestoreService.addRoutine(routine);

      _routines.add(
        WorkoutRoutine(
          id: id,
          userId: routine.userId,
          name: routine.name,
          scheduledDays: routine.scheduledDays,
          exercises: routine.exercises,
          createdAt: routine.createdAt,
        ),
      );

      notifyListeners();

    } catch (e) {

      _setError("Failed to save routine");
    }
  }

  Future<void> updateRoutine(WorkoutRoutine routine) async {

    try {

      await _firestoreService.updateRoutine(routine);

      final index =
      _routines.indexWhere((r) => r.id == routine.id);

      if (index != -1) {
        _routines[index] = routine;
      }

      notifyListeners();

    } catch (e) {

      _setError("Failed to update routine");
    }
  }

  Future<void> deleteRoutine(String routineId) async {

    try {

      await _firestoreService.deleteRoutine(routineId);

      _routines.removeWhere((r) => r.id == routineId);

      notifyListeners();

    } catch (e) {

      _setError("Failed to delete routine");
    }
  }

  List<WorkoutRoutine> getRoutinesForDay(int dayIndex) {

    return _routines
        .where((r) => r.scheduledDays.contains(dayIndex))
        .toList();
  }

  // ───────────────── WORKOUT LOGS ─────────────────

  Future<void> addWorkoutLog(WorkoutLog log) async {

    try {

      final id =
      await _firestoreService.addWorkoutLog(log);

      _workoutLogs.insert(
        0,
        WorkoutLog(
          id: id,
          userId: log.userId,
          routineId: log.routineId,
          routineName: log.routineName,
          date: log.date,
          status: log.status,
          exerciseLogs: log.exerciseLogs,
          durationMinutes: log.durationMinutes,
          notes: log.notes,
        ),
      );

      notifyListeners();

    } catch (e) {

      _setError("Failed to log workout");
    }
  }

  Future<void> updateWorkoutLog(WorkoutLog log) async {

    try {

      await _firestoreService.updateWorkoutLog(log);

      final index =
      _workoutLogs.indexWhere((l) => l.id == log.id);

      if (index != -1) {
        _workoutLogs[index] = log;
      }

      notifyListeners();

    } catch (e) {

      _setError("Failed to update log");
    }
  }

  List<WorkoutLog> get todaysLogs {

    final today = DateTime.now();

    return _workoutLogs.where((l) {

      return l.date.year == today.year &&
          l.date.month == today.month &&
          l.date.day == today.day;

    }).toList();
  }

  int get thisWeekCompletedCount {

    final weekStart = DateTime.now().subtract(
      Duration(days: DateTime.now().weekday - 1),
    );

    return _workoutLogs.where((l) {

      return l.status == 'completed' &&
          l.date.isAfter(weekStart);

    }).length;
  }

  // ───────────────── PROGRESS ─────────────────

  Future<void> addProgressEntry(
      ProgressEntry entry,
      ) async {

    try {

      final id =
      await _firestoreService.addProgressEntry(entry);

      _progressEntries.add(
        ProgressEntry(
          id: id,
          userId: entry.userId,
          date: entry.date,
          weightKg: entry.weightKg,
          chestCm: entry.chestCm,
          waistCm: entry.waistCm,
          armsCm: entry.armsCm,
          hipsCm: entry.hipsCm,
          notes: entry.notes,
        ),
      );

      _progressEntries.sort(
              (a, b) => a.date.compareTo(b.date));

      notifyListeners();

    } catch (e) {

      _setError("Failed to save progress");
    }
  }

  Future<void> deleteProgressEntry(String entryId) async {

    try {

      await _firestoreService.deleteProgressEntry(entryId);

      _progressEntries
          .removeWhere((e) => e.id == entryId);

      notifyListeners();

    } catch (e) {

      _setError("Failed to delete entry");
    }
  }

  // ───────────────── AI ─────────────────

  Future<void> _loadDailyTip() async {

    if (_userProfile == null) return;

    try {

      final recentCount = _workoutLogs
          .where(
            (l) => l.date.isAfter(
          DateTime.now().subtract(
            const Duration(days: 7),
          ),
        ),
      )
          .length;

      _dailyTip = await _aiService.getDailyTip(
        fitnessGoal: _userProfile!.fitnessGoal,
        recentWorkoutsCount: recentCount,
      );

      notifyListeners();

    } catch (e) {

      _dailyTip =
      "Stay consistent — every workout counts 💪";

      notifyListeners();
    }
  }

  Future<void> generateWorkoutPlan({
    required String goal,
    required int daysPerWeek,
    String? fitnessLevel,
  }) async {

    _isAiLoading = true;

    _aiError = null;

    _aiWorkoutPlan = '';

    notifyListeners();

    try {

      _aiWorkoutPlan =
      await _aiService.generateWorkoutPlan(
        fitnessGoal: goal,
        daysPerWeek: daysPerWeek,
        currentFitnessLevel: fitnessLevel,
      );

    } catch (e) {

      _aiError = e.toString();

    } finally {

      _isAiLoading = false;

      notifyListeners();
    }
  }

  Future<void> getImprovementSuggestions() async {

    if (_userProfile == null) return;

    _isAiLoading = true;

    _aiError = null;

    _aiSuggestions = '';

    notifyListeners();

    try {

      _aiSuggestions =
      await _aiService.getImprovementSuggestions(
        profile: _userProfile!,
        recentLogs: _workoutLogs,
      );

    } catch (e) {

      _aiError = e.toString();

    } finally {

      _isAiLoading = false;

      notifyListeners();
    }
  }

  Future<void> getDietSuggestions() async {

    if (_userProfile == null) return;

    _isAiLoading = true;

    _aiError = null;

    _aiDietSuggestions = '';

    notifyListeners();

    try {

      _aiDietSuggestions =
      await _aiService.getDietSuggestions(
        fitnessGoal: _userProfile!.fitnessGoal,
        weightKg: _userProfile!.weightKg,
      );

    } catch (e) {

      _aiError = e.toString();

    } finally {

      _isAiLoading = false;

      notifyListeners();
    }
  }

  // ───────────────── HELPERS ─────────────────

  void _setLoading(bool value) {

    _isLoading = value;

    notifyListeners();
  }

  void _setError(String? message) {

    _error = message;

    notifyListeners();
  }

  void clearError() {

    _error = null;

    _aiError = null;

    notifyListeners();
  }
}