// lib/models/workout_log.dart
// Records an actual workout session

class ExerciseLog {
  final String exerciseId;
  final String exerciseName;
  final int plannedSets;
  final int plannedReps;
  final int completedSets;
  final int completedReps;
  final int? actualDurationSeconds;

  ExerciseLog({
    required this.exerciseId,
    required this.exerciseName,
    required this.plannedSets,
    required this.plannedReps,
    required this.completedSets,
    required this.completedReps,
    this.actualDurationSeconds,
  });

  factory ExerciseLog.fromMap(Map<String, dynamic> map) {
    return ExerciseLog(
      exerciseId: map['exerciseId'] ?? '',
      exerciseName: map['exerciseName'] ?? '',
      plannedSets: map['plannedSets'] ?? 0,
      plannedReps: map['plannedReps'] ?? 0,
      completedSets: map['completedSets'] ?? 0,
      completedReps: map['completedReps'] ?? 0,
      actualDurationSeconds: map['actualDurationSeconds'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'plannedSets': plannedSets,
      'plannedReps': plannedReps,
      'completedSets': completedSets,
      'completedReps': completedReps,
      'actualDurationSeconds': actualDurationSeconds,
    };
  }
}

class WorkoutLog {
  final String id;
  final String userId;
  final String routineId;
  final String routineName;
  final DateTime date;
  final String status; // planned, completed, skipped
  final List<ExerciseLog> exerciseLogs;
  final int? durationMinutes;
  final String? notes;

  WorkoutLog({
    required this.id,
    required this.userId,
    required this.routineId,
    required this.routineName,
    required this.date,
    required this.status,
    required this.exerciseLogs,
    this.durationMinutes,
    this.notes,
  });

  factory WorkoutLog.fromMap(Map<String, dynamic> map, String id) {
    return WorkoutLog(
      id: id,
      userId: map['userId'] ?? '',
      routineId: map['routineId'] ?? '',
      routineName: map['routineName'] ?? '',
      date: map['date']?.toDate() ?? DateTime.now(),
      status: map['status'] ?? 'planned',
      exerciseLogs: (map['exerciseLogs'] as List<dynamic>? ?? [])
          .map((e) => ExerciseLog.fromMap(e as Map<String, dynamic>))
          .toList(),
      durationMinutes: map['durationMinutes'],
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'routineId': routineId,
      'routineName': routineName,
      'date': date,
      'status': status,
      'exerciseLogs': exerciseLogs.map((e) => e.toMap()).toList(),
      'durationMinutes': durationMinutes,
      'notes': notes,
    };
  }
}

// lib/models/progress_entry.dart
// Records body weight and measurements over time

class ProgressEntry {
  final String id;
  final String userId;
  final DateTime date;
  final double? weightKg;
  final double? chestCm;
  final double? waistCm;
  final double? armsCm;
  final double? hipsCm;
  final String? notes;

  ProgressEntry({
    required this.id,
    required this.userId,
    required this.date,
    this.weightKg,
    this.chestCm,
    this.waistCm,
    this.armsCm,
    this.hipsCm,
    this.notes,
  });

  factory ProgressEntry.fromMap(Map<String, dynamic> map, String id) {
    return ProgressEntry(
      id: id,
      userId: map['userId'] ?? '',
      date: map['date']?.toDate() ?? DateTime.now(),
      weightKg: (map['weightKg'] as num?)?.toDouble(),
      chestCm: (map['chestCm'] as num?)?.toDouble(),
      waistCm: (map['waistCm'] as num?)?.toDouble(),
      armsCm: (map['armsCm'] as num?)?.toDouble(),
      hipsCm: (map['hipsCm'] as num?)?.toDouble(),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': date,
      'weightKg': weightKg,
      'chestCm': chestCm,
      'waistCm': waistCm,
      'armsCm': armsCm,
      'hipsCm': hipsCm,
      'notes': notes,
    };
  }
}