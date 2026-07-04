# Lectra

Lectra is a Flutter app for managing your college/university timetable and tracking attendance — built with Material 3, offline-first local storage, and reminder notifications so you never miss a class.

## Features

- **Dashboard / Today's Schedule** — A vertical timeline of today's classes as the home screen, with the current or upcoming class highlighted live. Switch to a traditional weekly timetable grid view without leaving the screen.
- **Subjects** — Add and manage subjects with a name, course code, nickname, faculty name, and a custom accent color used consistently across the app.
- **Weekly Timetable** — Assign lecture slots to subjects across the week; edits made from a subject's detail page are reflected instantly on the dashboard.
- **Attendance Tracking** — Mark each class as Present, Absent, or Cancelled, and view per-subject attendance percentage (cancelled classes are excluded from the calculation) via a pie chart.
- **Notifications & Reminders** — Local notifications remind you ahead of upcoming classes, with automatic follow-up reminders and cancellation handling per subject.
- **Dynamic Theming** — Material You dynamic color support on Android 12+, with light/dark mode controlled from Settings.
- **Offline-First** — All data is stored locally on-device using a structured local database; no account or internet connection required.

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | [Flutter](https://flutter.dev) |
| State Management | [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) |
| Routing | [go_router](https://pub.dev/packages/go_router) |
| Local Database | [drift](https://pub.dev/packages/drift) |
| Notifications | [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) + [timezone](https://pub.dev/packages/timezone) |
| Theming | Material 3 with [dynamic_color](https://pub.dev/packages/dynamic_color) |

## Project Structure

```
lib/
├── core/
│   ├── constants/       # App-wide constants and route paths
│   ├── database/        # Drift database schema and providers
│   ├── routing/         # go_router configuration
│   ├── theme/           # App theme and subject color palette
│   └── utils/           # Shared utility helpers
├── features/
│   ├── attendance/      # Attendance model, repository, controller
│   ├── dashboard/       # Home screen: daily timeline + weekly grid
│   ├── notifications/   # Notification scheduling service
│   ├── settings/        # App settings (theme mode, etc.)
│   ├── subjects/        # Subject CRUD, forms, color picker
│   └── timetable/       # Weekly timetable model/repository
├── shared/
│   └── widgets/         # Reusable widgets (pie chart, scaffold)
├── app.dart             # Root MaterialApp.router widget
├── bootstrap.dart        # App startup/initialization
└── main.dart             # Entry point
```

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- Android Studio / VS Code with the Flutter and Dart extensions
- A connected Android device or emulator
- **JDK 17** (required by the Android Gradle Plugin — see [Build Notes](#-build-notes) below)

### Installation

```bash
git clone https://github.com/<your-username>/lectra.git
cd lectra
flutter pub get
flutter run
```

### Building a release APK

```bash
flutter build apk --release --split-per-abi
```

Or build an App Bundle for Play Store distribution:

```bash
flutter build appbundle --release
```

## Build Notes

- This project targets **Java 17**. If your system's default JDK is older (e.g. 1.8), point Gradle to a JDK 17 installation via `android/gradle.properties`:
  ```properties
  org.gradle.java.home=C:\\Program Files\\Eclipse Adoptium\\jdk-17.0.19.10-hotspot
  ```
- `minifyEnabled` and `shrinkResources` are enabled in the release build type to reduce APK size via code and resource shrinking.
- Custom adaptive launcher icons are generated with [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons); see `pubspec.yaml` for configuration.

