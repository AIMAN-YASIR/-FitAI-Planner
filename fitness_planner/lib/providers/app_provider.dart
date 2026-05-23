// lib/providers/app_provider.dart
// Central state management using Provider

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../models/exercise.dart';
import '../models/workout_log.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/ai_service.dart';

class AppProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final AIService _aiService = AIService();

  // ─── STATE ─────────────────────────────────────────────────────────────────

  User? _currentUser;
  UserProfile? _userProfile;
  List<WorkoutRoutine> _routines = [];
  List<Exercise> _exercises = [];
  List<WorkoutLog> _workoutLogs = [];
  List<ProgressEntry> _progressEntries = [];

  String _dailyTip = '';
  bool _isLoading = false;
  bool _isInitializing = true; // true only until first auth check completes
  String? _error;

  // AI state
  String _aiWorkoutPlan = '';
  String _aiSuggestions = '';
  String _aiDietSuggestions = '';
  bool _isAiLoading = false;
  String? _aiError;

  // ─── GETTERS ───────────────────────────────────────────────────────────────

  User? get currentUser => _currentUser;
  UserProfile? get userProfile => _userProfile;
  List<WorkoutRoutine> get routines => _routines;
  List<Exercise> get exercises => _exercises;
  List<WorkoutLog> get workoutLogs => _workoutLogs;
  List<ProgressEntry> get progressEntries => _progressEntries;
  String get dailyTip => _dailyTip;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get error => _error;
  String get aiWorkoutPlan => _aiWorkoutPlan;
  String get aiSuggestions => _aiSuggestions;
  String get aiDietSuggestions => _aiDietSuggestions;
  bool get isAiLoading => _isAiLoading;
  String? get aiError => _aiError;

  bool get isAuthenticated => _currentUser != null;

  // ─── AUTH ──────────────────────────────────────────────────────────────────

  void setUser(User? user) {
    // Guard: if same user is already loaded (e.g. authStateChanges fires
    // AFTER signIn already set _currentUser), skip re-loading data.
    if (user != null && _currentUser?.uid == user.uid && _userProfile != null) {
      _isInitializing = false;
      return; // Data already loaded — no notifyListeners needed
    }

    _currentUser = user;
    _isInitializing = false;

    if (user != null) {
      // Load data in background; isInitializing=false means AuthGate
      // already shows MainShell — no splash loop.
      _loadUserData();
    } else {
      _clearData();
      notifyListeners();
    }
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
    _error = null;
    try {
      _userProfile = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        fitnessGoal: fitnessGoal,
        heightCm: heightCm,
        weightKg: weightKg,
      );
      // Set currentUser immediately so AuthGate switches to MainShell.
      // authStateChanges stream will also fire and call setUser() —
      // the uid guard in setUser() prevents a second _loadUserData() call.
      _currentUser = _authService.currentUser;
      _isInitializing = false;
      _setLoading(false); // stop spinner BEFORE navigating
      notifyListeners();
      // Load data AFTER spinner is stopped and navigation has happened
      if (_currentUser != null) _loadUserData(); // NOT awaited — runs in background
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    _setLoading(true);
    _error = null;
    try {
      final user = await _authService.signIn(email: email, password: password);
      _currentUser = user;
      _isInitializing = false;
      _setLoading(false); // stop spinner BEFORE navigating
      notifyListeners();
      if (user != null) _loadUserData(); // NOT awaited — runs in background
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    // authStateChanges will fire null -> setUser(null) -> _clearData().
    // Pre-clear here so UI updates immediately without waiting for stream.
    _currentUser = null;
    _isInitializing = false;
    _clearData();
    notifyListeners();
  }

  // ─── DATA LOADING ──────────────────────────────────────────────────────────

  // Separate flag for background data loading — does NOT affect AuthGate routing.
  bool _isDataLoading = false;
  bool get isDataLoading => _isDataLoading;

  Future<void> _loadUserData() async {
    if (_currentUser == null) return;
    // Prevent concurrent loads
    if (_isDataLoading) return;
    _isDataLoading = true;
    notifyListeners();
    try {
      // Seed exercises if not done yet (no-op if already seeded)
      await _firestoreService.seedBuiltInExercises();

      // Load all user data in parallel for speed
      final results = await Future.wait([
        _firestoreService.getUserProfile(_currentUser!.uid),
        _firestoreService.getExercises(_currentUser!.uid),
        _firestoreService.getUserRoutines(_currentUser!.uid),
        _firestoreService.getUserLogs(_currentUser!.uid),
        _firestoreService.getProgressEntries(_currentUser!.uid),
      ]);

      _userProfile   = results[0] as UserProfile?;
      _exercises     = results[1] as List<Exercise>;
      _routines      = results[2] as List<WorkoutRoutine>;
      _workoutLogs   = results[3] as List<WorkoutLog>;
      _progressEntries = results[4] as List<ProgressEntry>;

      // Load daily tip in background (non-blocking)
      _loadDailyTip();
    } catch (e) {
      _setError('Failed to load data: $e');
    } finally {
      _isInitializing = false;
      _isDataLoading = false;
      // Do NOT call _setLoading(false) here — that flag belongs to auth actions only
      notifyListeners();
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
  }

  // ─── USER PROFILE ──────────────────────────────────────────────────────────

  Future<void> updateProfile(UserProfile profile) async {
    try {
      await _firestoreService.updateUserProfile(profile);
      _userProfile = profile;
      notifyListeners();
    } catch (e) {
      _setError('Failed to update profile: $e');
    }
  }

  // ─── EXERCISES ─────────────────────────────────────────────────────────────

  Future<void> addCustomExercise(Exercise exercise) async {
    try {
      final id = await _firestoreService.addExercise(exercise);
      _exercises.add(Exercise(
        id: id,
        name: exercise.name,
        muscleGroup: exercise.muscleGroup,
        equipment: exercise.equipment,
        description: exercise.description,
        isCustom: true,
        userId: _currentUser?.uid,
      ));
      notifyListeners();
    } catch (e) {
      _setError('Failed to add exercise: $e');
    }
  }

  // Get exercises filtered by muscle group
  List<Exercise> getExercisesByMuscle(String muscleGroup) {
    if (muscleGroup == 'All') return _exercises;
    return _exercises.where((e) => e.muscleGroup == muscleGroup).toList();
  }

  List<String> get muscleGroups {
    final groups = _exercises.map((e) => e.muscleGroup).toSet().toList();
    groups.sort();
    return ['All', ...groups];
  }

  // ─── WORKOUT ROUTINES ──────────────────────────────────────────────────────

  Future<void> addRoutine(WorkoutRoutine routine) async {
    try {
      String id;
      try {
        // Try Firebase first
        id = await _firestoreService.addRoutine(routine);
      } catch (_) {
        // Firebase unavailable — generate local ID
        id = 'local_${DateTime.now().millisecondsSinceEpoch}';
      }
      _routines.add(WorkoutRoutine(
        id: id,
        userId: routine.userId,
        name: routine.name,
        scheduledDays: routine.scheduledDays,
        exercises: routine.exercises,
        createdAt: routine.createdAt,
      ));
      notifyListeners();
    } catch (e) {
      _setError('Failed to save routine: $e');
    }
  }

  Future<void> updateRoutine(WorkoutRoutine routine) async {
    try {
      try {
        await _firestoreService.updateRoutine(routine);
      } catch (_) {
        // Firebase unavailable — update locally only
      }
      final idx = _routines.indexWhere((r) => r.id == routine.id);
      if (idx != -1) _routines[idx] = routine;
      notifyListeners();
    } catch (e) {
      _setError('Failed to update routine: $e');
    }
  }

  Future<void> deleteRoutine(String routineId) async {
    try {
      try {
        await _firestoreService.deleteRoutine(routineId);
      } catch (_) {
        // Firebase unavailable — delete locally only
      }
      _routines.removeWhere((r) => r.id == routineId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete routine: $e');
    }
  }

  // Get routines for a specific day (0=Mon, 6=Sun)
  List<WorkoutRoutine> getRoutinesForDay(int dayIndex) {
    return _routines.where((r) => r.scheduledDays.contains(dayIndex)).toList();
  }

  // ─── WORKOUT LOGS ──────────────────────────────────────────────────────────

  Future<void> addWorkoutLog(WorkoutLog log) async {
    try {
      final id = await _firestoreService.addWorkoutLog(log);
      _workoutLogs.insert(0, WorkoutLog(
        id: id,
        userId: log.userId,
        routineId: log.routineId,
        routineName: log.routineName,
        date: log.date,
        status: log.status,
        exerciseLogs: log.exerciseLogs,
        durationMinutes: log.durationMinutes,
        notes: log.notes,
      ));
      notifyListeners();
    } catch (e) {
      _setError('Failed to log workout: $e');
    }
  }

  Future<void> updateWorkoutLog(WorkoutLog log) async {
    try {
      await _firestoreService.updateWorkoutLog(log);
      final idx = _workoutLogs.indexWhere((l) => l.id == log.id);
      if (idx != -1) _workoutLogs[idx] = log;
      notifyListeners();
    } catch (e) {
      _setError('Failed to update log: $e');
    }
  }

  // Get today's logs
  List<WorkoutLog> get todaysLogs {
    final today = DateTime.now();
    return _workoutLogs.where((l) =>
    l.date.year == today.year &&
        l.date.month == today.month &&
        l.date.day == today.day
    ).toList();
  }

  // Get this week's completed workouts count
  int get thisWeekCompletedCount {
    final weekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    return _workoutLogs.where((l) =>
    l.status == 'completed' &&
        l.date.isAfter(weekStart)
    ).length;
  }

  // ─── PROGRESS ──────────────────────────────────────────────────────────────

  Future<void> addProgressEntry(ProgressEntry entry) async {
    try {
      final id = await _firestoreService.addProgressEntry(entry);
      _progressEntries.add(ProgressEntry(
        id: id,
        userId: entry.userId,
        date: entry.date,
        weightKg: entry.weightKg,
        chestCm: entry.chestCm,
        waistCm: entry.waistCm,
        armsCm: entry.armsCm,
        hipsCm: entry.hipsCm,
        notes: entry.notes,
      ));
      _progressEntries.sort((a, b) => a.date.compareTo(b.date));
      notifyListeners();
    } catch (e) {
      _setError('Failed to save progress: $e');
    }
  }

  Future<void> deleteProgressEntry(String entryId) async {
    try {
      await _firestoreService.deleteProgressEntry(entryId);
      _progressEntries.removeWhere((e) => e.id == entryId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete entry: $e');
    }
  }

  // ─── AI FEATURES ───────────────────────────────────────────────────────────

  Future<void> _loadDailyTip() async {
    if (_userProfile == null) return;
    try {
      final recentCount = _workoutLogs
          .where((l) => l.date.isAfter(DateTime.now().subtract(const Duration(days: 7))))
          .length;
      _dailyTip = await _aiService.getDailyTip(
        fitnessGoal: _userProfile!.fitnessGoal,
        recentWorkoutsCount: recentCount,
      );
      notifyListeners();
    } catch (_) {
      _dailyTip = 'Stay consistent — every workout counts toward your goal!';
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
      _aiWorkoutPlan = await _aiService.generateWorkoutPlan(
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
      _aiSuggestions = await _aiService.getImprovementSuggestions(
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
      _aiDietSuggestions = await _aiService.getDietSuggestions(
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

  // ─── HELPERS ───────────────────────────────────────────────────────────────

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