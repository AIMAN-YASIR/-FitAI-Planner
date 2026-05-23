// lib/models/user_profile.dart
// User profile data model

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final double? heightCm;
  final double? weightKg;
  final String fitnessGoal;
  final DateTime? createdAt;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.heightCm,
    this.weightKg,
    required this.fitnessGoal,
    this.createdAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfile(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      heightCm: (map['heightCm'] as num?)?.toDouble(),
      weightKg: (map['weightKg'] as num?)?.toDouble(),
      fitnessGoal: map['fitnessGoal'] ?? 'Maintain',
      createdAt: map['createdAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'fitnessGoal': fitnessGoal,
      'createdAt': createdAt,
    };
  }

  UserProfile copyWith({
    String? name,
    String? email,
    double? heightCm,
    double? weightKg,
    String? fitnessGoal,
  }) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      createdAt: createdAt,
    );
  }
}