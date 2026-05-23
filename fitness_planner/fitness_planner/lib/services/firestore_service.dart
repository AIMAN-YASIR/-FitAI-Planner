// lib/services/firestore_service.dart
// All Firestore CRUD operations for the app

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../models/exercise.dart';
import '../models/workout_log.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── USER PROFILE ──────────────────────────────────────────────────────────

  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserProfile.fromMap(doc.data()!, uid);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    await _db.collection('users').doc(profile.uid).update(profile.toMap());
  }

  // ─── EXERCISES ─────────────────────────────────────────────────────────────

  // Get pre-built + user's custom exercises
  Future<List<Exercise>> getExercises(String userId) async {
    try {
      // Pre-built exercises (no userId)
      final builtIn = await _db
          .collection('exercises')
          .where('isCustom', isEqualTo: false)
          .get();

      // User's custom exercises
      final custom = await _db
          .collection('exercises')
          .where('userId', isEqualTo: userId)
          .get();

      final all = [
        ...builtIn.docs.map((d) => Exercise.fromMap(d.data(), d.id)),
        ...custom.docs.map((d) => Exercise.fromMap(d.data(), d.id)),
      ];
      return all;
    } catch (e) {
      return [];
    }
  }

  Future<String> addExercise(Exercise exercise) async {
    final doc = await _db.collection('exercises').add(exercise.toMap());
    return doc.id;
  }

  // Seed built-in exercises (call once on first run)
  Future<void> seedBuiltInExercises() async {
    final existing = await _db
        .collection('exercises')
        .where('isCustom', isEqualTo: false)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) return; // Already seeded

    final exercises = _getBuiltInExercises();
    final batch = _db.batch();
    for (final ex in exercises) {
      final ref = _db.collection('exercises').doc();
      batch.set(ref, ex.toMap());
    }
    await batch.commit();
  }

  // ─── WORKOUT ROUTINES ──────────────────────────────────────────────────────

  Future<List<WorkoutRoutine>> getUserRoutines(String userId) async {
    try {
      final snap = await _db
          .collection('routines')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: false)
          .get();
      return snap.docs.map((d) => WorkoutRoutine.fromMap(d.data(), d.id)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<String> addRoutine(WorkoutRoutine routine) async {
    final doc = await _db.collection('routines').add(routine.toMap());
    return doc.id;
  }

  Future<void> updateRoutine(WorkoutRoutine routine) async {
    await _db.collection('routines').doc(routine.id).update(routine.toMap());
  }

  Future<void> deleteRoutine(String routineId) async {
    await _db.collection('routines').doc(routineId).delete();
  }

  // ─── WORKOUT LOGS ──────────────────────────────────────────────────────────

  Future<List<WorkoutLog>> getUserLogs(String userId, {int limitDays = 30}) async {
    try {
      final since = DateTime.now().subtract(Duration(days: limitDays));
      final snap = await _db
          .collection('workout_logs')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThan: Timestamp.fromDate(since))
          .orderBy('date', descending: true)
          .get();
      return snap.docs.map((d) => WorkoutLog.fromMap(d.data(), d.id)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<String> addWorkoutLog(WorkoutLog log) async {
    final doc = await _db.collection('workout_logs').add(log.toMap());
    return doc.id;
  }

  Future<void> updateWorkoutLog(WorkoutLog log) async {
    await _db.collection('workout_logs').doc(log.id).update(log.toMap());
  }

  // ─── PROGRESS ENTRIES ──────────────────────────────────────────────────────

  Future<List<ProgressEntry>> getProgressEntries(String userId) async {
    try {
      final snap = await _db
          .collection('progress')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: false)
          .get();
      return snap.docs.map((d) => ProgressEntry.fromMap(d.data(), d.id)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<String> addProgressEntry(ProgressEntry entry) async {
    final doc = await _db.collection('progress').add(entry.toMap());
    return doc.id;
  }

  Future<void> deleteProgressEntry(String entryId) async {
    await _db.collection('progress').doc(entryId).delete();
  }

  // ─── BUILT-IN EXERCISE DATA ────────────────────────────────────────────────

  List<Exercise> _getBuiltInExercises() {
    final data = [
      // CHEST
      {'name': 'Barbell Bench Press', 'muscleGroup': 'Chest', 'equipment': 'Barbell', 'description': 'Compound chest press lying on bench'},
      {'name': 'Dumbbell Chest Press', 'muscleGroup': 'Chest', 'equipment': 'Dumbbells', 'description': 'Chest press with dumbbells for range of motion'},
      {'name': 'Push-Ups', 'muscleGroup': 'Chest', 'equipment': 'None', 'description': 'Classic bodyweight chest exercise'},
      {'name': 'Chest Fly', 'muscleGroup': 'Chest', 'equipment': 'Dumbbells', 'description': 'Isolation chest fly movement'},
      {'name': 'Incline Bench Press', 'muscleGroup': 'Chest', 'equipment': 'Barbell', 'description': 'Targets upper chest'},
      // BACK
      {'name': 'Pull-Ups', 'muscleGroup': 'Back', 'equipment': 'Pull-Up Bar', 'description': 'Bodyweight compound back exercise'},
      {'name': 'Bent-Over Row', 'muscleGroup': 'Back', 'equipment': 'Barbell', 'description': 'Compound rowing movement for back thickness'},
      {'name': 'Lat Pulldown', 'muscleGroup': 'Back', 'equipment': 'Cable Machine', 'description': 'Lat-focused pulling movement'},
      {'name': 'Seated Cable Row', 'muscleGroup': 'Back', 'equipment': 'Cable Machine', 'description': 'Horizontal pulling for mid-back'},
      {'name': 'Deadlift', 'muscleGroup': 'Back', 'equipment': 'Barbell', 'description': 'King of all compound lifts'},
      // LEGS
      {'name': 'Barbell Squat', 'muscleGroup': 'Legs', 'equipment': 'Barbell', 'description': 'Fundamental lower body compound lift'},
      {'name': 'Leg Press', 'muscleGroup': 'Legs', 'equipment': 'Machine', 'description': 'Machine-based quad-dominant pressing'},
      {'name': 'Romanian Deadlift', 'muscleGroup': 'Legs', 'equipment': 'Barbell', 'description': 'Hamstring-focused deadlift variation'},
      {'name': 'Lunges', 'muscleGroup': 'Legs', 'equipment': 'None', 'description': 'Unilateral leg exercise for balance and strength'},
      {'name': 'Leg Curl', 'muscleGroup': 'Legs', 'equipment': 'Machine', 'description': 'Isolation for hamstrings'},
      {'name': 'Calf Raises', 'muscleGroup': 'Legs', 'equipment': 'None', 'description': 'Isolation exercise for calves'},
      // SHOULDERS
      {'name': 'Overhead Press', 'muscleGroup': 'Shoulders', 'equipment': 'Barbell', 'description': 'Compound shoulder press overhead'},
      {'name': 'Dumbbell Lateral Raises', 'muscleGroup': 'Shoulders', 'equipment': 'Dumbbells', 'description': 'Isolation for lateral deltoid'},
      {'name': 'Front Raises', 'muscleGroup': 'Shoulders', 'equipment': 'Dumbbells', 'description': 'Isolation for front deltoid'},
      {'name': 'Arnold Press', 'muscleGroup': 'Shoulders', 'equipment': 'Dumbbells', 'description': 'Rotational shoulder press variation'},
      // ARMS
      {'name': 'Barbell Curl', 'muscleGroup': 'Arms', 'equipment': 'Barbell', 'description': 'Classic bicep curl with barbell'},
      {'name': 'Hammer Curl', 'muscleGroup': 'Arms', 'equipment': 'Dumbbells', 'description': 'Neutral grip curl for brachialis'},
      {'name': 'Tricep Dips', 'muscleGroup': 'Arms', 'equipment': 'None', 'description': 'Bodyweight tricep compound movement'},
      {'name': 'Skull Crushers', 'muscleGroup': 'Arms', 'equipment': 'Barbell', 'description': 'Lying tricep extension'},
      {'name': 'Tricep Pushdown', 'muscleGroup': 'Arms', 'equipment': 'Cable Machine', 'description': 'Cable isolation for triceps'},
      // CORE
      {'name': 'Plank', 'muscleGroup': 'Core', 'equipment': 'None', 'description': 'Isometric core stability exercise'},
      {'name': 'Crunches', 'muscleGroup': 'Core', 'equipment': 'None', 'description': 'Basic abdominal crunch movement'},
      {'name': 'Russian Twists', 'muscleGroup': 'Core', 'equipment': 'None', 'description': 'Rotational core exercise'},
      {'name': 'Leg Raises', 'muscleGroup': 'Core', 'equipment': 'None', 'description': 'Lower ab isolation exercise'},
      {'name': 'Mountain Climbers', 'muscleGroup': 'Core', 'equipment': 'None', 'description': 'Dynamic core and cardio exercise'},
    ];

    return data.map((d) => Exercise(
      id: '',
      name: d['name']!,
      muscleGroup: d['muscleGroup']!,
      equipment: d['equipment']!,
      description: d['description']!,
      isCustom: false,
    )).toList();
  }
}