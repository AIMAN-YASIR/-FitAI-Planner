
# 🏋️ FitAI Planner

An AI-powered Fitness & Workout Planner built with Flutter. 
Plan workouts, track progress, and get personalized AI suggestions — all in one app.

---

## 📱 Features

### 🗓️ Workout Planner
- Create custom workout routines (e.g., "Chest Day", "Leg Day")
- Add exercises with Sets, Reps, and Duration
- Schedule routines on specific days of the week
- Edit and delete routines

### 📚 Exercise Library
- 30+ pre-built exercises across 6 muscle groups (Chest, Back, Legs, Shoulders, Arms, Core)
- Search exercises by name or muscle group
- Filter by muscle group chips
- Add custom exercises to your library
- Tap any exercise to see full details and how-to description

### 📊 Workout Tracking
- Log actual performance: sets completed, reps achieved
- Mark workouts as completed or skipped
- View recent workout history
- Weekly completion stats

### 📈 Progress Tracking
- Log body weight over time
- Track body measurements: chest, waist, arms
- Line chart for weight progress (fl_chart)
- Bar chart for weekly workout frequency
- Delete old entries

### 👤 User Profile
- Store name, height, weight, fitness goal
- Edit profile anytime
- View weekly stats summary
- Goals: Lose Weight / Gain Muscle / Maintain

### 🤖 AI Features (via OpenRouter)
| Feature | Description |
|---|---|
| Smart Workout Generator | Enter goal + days/week → get full weekly plan |
| Improvement Suggestions | AI analyzes logs → gives personalized tips |
| Diet Suggestions | Meal ideas based on your fitness goal |
| Daily Tip | One short motivational tip on home screen |

---

## 🛠️ Tech Stack

| Category | Package |
|---|---|
| Framework | Flutter 3.x |
| State Management | Provider ^6.1.2 |
| Backend | Firebase (Firestore + Auth) |
| Charts | fl_chart ^0.68.0 |
| AI | OpenRouter API (gpt-4o-mini) |
| HTTP | http ^1.2.1 |
| Fonts | google_fonts ^6.2.1 |
| Date Format | intl ^0.19.0 |
| Unique IDs | uuid ^4.4.0 |
| Local Storage | shared_preferences ^2.3.2 |

---

## 🚀 Getting Started

### 1. Prerequisites
- Flutter SDK `>=3.2.0`
- Dart SDK `>=3.2.0`
- Firebase project (optional — app works offline too)
- OpenRouter API key

### 2. Clone & Install

```bash
git clone https://github.com/AIMAN-YASIR/-FitAI-Planner.git
cd fitness_planner
flutter pub get
```

### 3. Firebase Setup

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Connect your Firebase project
flutterfire configure
```

This generates `lib/firebase_options.dart` automatically.

In Firebase Console:
- Enable **Email/Password** Authentication
- Create **Firestore Database** (start in test mode)

### 4. OpenRouter API Key

Open `lib/services/ai_service.dart` and replace:

```dart
static const String apiKey = 'YOUR_OPENROUTER_API_KEY_HERE';
```

Get your free API key at: https://openrouter.ai

### 5. Run the App

```bash
flutter run
```

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point, routing, MainShell
├── firebase_options.dart        # Firebase config (auto-generated)
│
├── models/
│   ├── user_profile.dart        # User profile data model
│   ├── exercise.dart            # Exercise + WorkoutRoutine + WorkoutExercise
│   └── workout_log.dart         # WorkoutLog + ExerciseLog + ProgressEntry
│
├── providers/
│   └── app_provider.dart        # Central state (Provider pattern)
│
├── services/
│   ├── auth_service.dart        # Firebase Auth (signup, signin, signout)
│   ├── firestore_service.dart   # All Firestore CRUD operations
│   └── ai_service.dart          # OpenRouter API calls
│
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── home/
│   │   └── home_screen.dart     # Dashboard with daily tip & today's workouts
│   ├── workout/
│   │   ├── workout_list_screen.dart
│   │   ├── create_routine_screen.dart
│   │   └── workout_detail_screen.dart
│   ├── exercise/
│   │   └── exercise_library_screen.dart
│   ├── progress/
│   │   └── progress_screen.dart  # fl_chart graphs
│   ├── profile/
│   │   └── profile_screen.dart
│   └── ai/
│       └── ai_features_screen.dart
│
├── widgets/
│   └── common_widgets.dart      # LoadingOverlay, StatCard, EmptyState, ErrorCard, etc.
│
└── utils/
    ├── constants.dart           # AppColors, AppStrings, FitnessGoals, DayNames
    ├── constrant.dart           # Re-exports constants.dart (typo alias)
    └── app_theme.dart           # Dark Material theme
```

---

## 🗄️ Firebase Schema

```
Firestore/
├── users/{uid}
│   ├── name, email, heightCm, weightKg
│   ├── fitnessGoal, createdAt
│
├── exercises/{id}
│   ├── name, muscleGroup, equipment
│   ├── description, isCustom, userId
│
├── routines/{id}
│   ├── userId, name, scheduledDays[]
│   ├── exercises[], createdAt
│
├── workout_logs/{id}
│   ├── userId, routineId, routineName
│   ├── date, status (completed/skipped)
│   └── exerciseLogs[]
│
└── progress/{id}
    ├── userId, date
    └── weightKg, chestCm, waistCm, armsCm
```

---

## 🔑 Environment Variables

| Variable | Location | Description |
|---|---|---|
| OpenRouter API Key | `lib/services/ai_service.dart` | For AI features |
| Firebase Config | `lib/firebase_options.dart` | Auto-generated by FlutterFire CLI |

---

## 📦 Key Packages

```yaml
dependencies:
  firebase_core: ^3.1.0
  firebase_auth: ^5.1.0
  cloud_firestore: ^5.0.0
  provider: ^6.1.2
  fl_chart: ^0.68.0
  http: ^1.2.1
  google_fonts: ^6.2.1
  intl: ^0.19.0
  uuid: ^4.4.0
  shared_preferences: ^2.3.2
```

Install all:
```bash
flutter pub get
```

---

*Built with Flutter 💙 | AI powered by OpenRouter 🤖 | Backend by Firebase 🔥*
