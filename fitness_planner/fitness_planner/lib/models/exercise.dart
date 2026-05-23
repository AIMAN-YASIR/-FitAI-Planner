// lib/models/exercise.dart
// Exercise data model

class Exercise {
  final String id;
  final String name;
  final String muscleGroup;
  final String equipment;
  final String description;
  final bool isCustom;
  final String? userId; // null for pre-built exercises

  Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    this.description = '',
    this.isCustom = false,
    this.userId,
  });

  factory Exercise.fromMap(Map<String, dynamic> map, String id) {
    return Exercise(
      id: id,
      name: map['name'] ?? '',
      muscleGroup: map['muscleGroup'] ?? '',
      equipment: map['equipment'] ?? 'None',
      description: map['description'] ?? '',
      isCustom: map['isCustom'] ?? false,
      userId: map['userId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'muscleGroup': muscleGroup,
      'equipment': equipment,
      'description': description,
      'isCustom': isCustom,
      'userId': userId,
    };
  }
}

// lib/models/workout_exercise.dart
// An exercise within a workout routine

class WorkoutExercise {
  final String exerciseId;
  final String exerciseName;
  final int sets;
  final int reps;
  final int? durationSeconds; // optional: for time-based exercises
  final String? notes;

  WorkoutExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
    required this.reps,
    this.durationSeconds,
    this.notes,
  });

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) {
    return WorkoutExercise(
      exerciseId: map['exerciseId'] ?? '',
      exerciseName: map['exerciseName'] ?? '',
      sets: map['sets'] ?? 3,
      reps: map['reps'] ?? 10,
      durationSeconds: map['durationSeconds'],
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'sets': sets,
      'reps': reps,
      'durationSeconds': durationSeconds,
      'notes': notes,
    };
  }

  WorkoutExercise copyWith({int? sets, int? reps, int? durationSeconds, String? notes}) {
    return WorkoutExercise(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      notes: notes ?? this.notes,
    );
  }
}

// lib/models/workout_routine.dart
// A named workout routine (e.g., "Chest Day")

class WorkoutRoutine {
  final String id;
  final String userId;
  final String name;
  final List<int> scheduledDays; // 0=Mon, 6=Sun
  final List<WorkoutExercise> exercises;
  final DateTime createdAt;

  WorkoutRoutine({
    required this.id,
    required this.userId,
    required this.name,
    required this.scheduledDays,
    required this.exercises,
    required this.createdAt,
  });

  factory WorkoutRoutine.fromMap(Map<String, dynamic> map, String id) {
    return WorkoutRoutine(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      scheduledDays: List<int>.from(map['scheduledDays'] ?? []),
      exercises: (map['exercises'] as List<dynamic>? ?? [])
          .map((e) => WorkoutExercise.fromMap(e as Map<String, dynamic>))
          .toList(),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'scheduledDays': scheduledDays,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'createdAt': createdAt,
    };
  }
}