# Lectra

Lectra is a Flutter app for tracking class timetables and attendance. It lets students record their weekly lecture schedule, mark attendance for each occurrence, and see per-subject attendance percentages at a glance — with reminder notifications so nothing gets forgotten.

## Features

- **Weekly timetable** — define recurring lecture slots per subject (day, start/end time, room) and view them as a weekly grid or a daily timeline.
- **Attendance tracking** — mark each class occurrence as Present, Absent, or Cancelled; cancelled classes are excluded from attendance percentage calculations.
- **Per-subject analytics** — attendance stats, history, and a calendar view for each subject, plus a pie-chart breakdown.
- **Class reminders** — local notifications before a class starts, when it starts, right after it ends, and a follow-up nudge if attendance still hasn't been marked (automatically cancelled once it is).
- **Dynamic theming** — Material 3 theming with Android 12+ dynamic color support, and a user-selectable light/dark/system theme mode.
- **In-app OTA updates** — checks GitHub Releases once a day (only when the app is opened) for a newer signed-in-CI APK and prompts the user to install, with live download progress.
- **Ads** — banner and interstitial ads via Google Mobile Ads, using Google's test ad unit IDs automatically in debug builds.

## Getting Started

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # generates the Drift database code
flutter run
```

### Configuration checklist before building a release

- **AdMob** — set your real Application ID in `android/app/src/main/AndroidManifest.xml` (`com.google.android.gms.ads.APPLICATION_ID`) and replace the placeholder release ad unit IDs in `lib/features/ads/ad_config.dart`. Debug builds automatically use Google's test ad units, so this only matters for release builds.
- **OTA updates** — `lib/core/constants/update_constants.dart` points at this repo's GitHub Releases. Update `githubOwner`/`githubRepo` if you fork this project.

## Architecture

The codebase follows a feature-first structure with a small shared `core/` layer, using [Riverpod](https://riverpod.dev/) for state management, [go_router](https://pub.dev/packages/go_router) for navigation, and [Drift](https://drift.simonbinder.eu/) (SQLite) for persistence.

```
lib/
├── main.dart                # Entry point — delegates to bootstrap()
├── bootstrap.dart           # Engine init: notifications, AdMob, runApp
├── app.dart                 # Root widget: theming, routing, update prompt
│
├── core/
│   ├── database/             # Drift tables & generated database (app_database.dart)
│   ├── routing/               # go_router configuration
│   ├── constants/              # App-wide constants (name, routes, update config)
│   ├── services/                 # Update checking/installing service + controller
│   ├── theme/                     # Material 3 theme + subject color palette
│   └── utils/                      # Small shared helpers (e.g. subject lookup)
│
├── features/
│   ├── dashboard/            # Home screen: today's schedule + weekly grid toggle
│   ├── subjects/              # CRUD for subjects, subject detail, weekly slot editing
│   ├── timetable/               # Timetable entry model/repository/controller
│   ├── attendance/               # Attendance status, records, aggregated stats
│   ├── notifications/             # Local notification scheduling for class reminders
│   ├── settings/                    # Theme mode and other user preferences
│   └── ads/                          # AdMob configuration, banner widget, interstitial manager
│
└── shared/widgets/                  # Cross-feature widgets (scaffold, pie chart, update dialog)
```

Each feature under `features/` generally follows the same internal layering:

| Layer | Responsibility |
|---|---|
| `model.dart` | Immutable domain models, decoupled from the Drift-generated classes |
| `repository.dart` | Data access — reads/writes against the Drift database |
| `controller.dart` | Riverpod state/business logic exposed to the UI |
| `screen.dart` / `widgets/` | UI |

### Navigation

`AppRouter` (in `core/routing/app_router.dart`) defines a single `StatefulShellRoute.indexedStack` that hosts the bottom navigation tabs (Dashboard, Subjects, Settings), each with its own navigator so per-tab state survives switching tabs. Add/Edit Subject is a real nested route rather than a dialog, so it participates in the same navigation stack.

### Data model

Persistence is handled by Drift with two core tables defined in `core/database/app_database.dart`:

- **Subjects** — name, optional code/nickname/faculty name, accent color.
- **WeeklyLectureSlots** — recurring weekly slots (day of week, start/end minutes since midnight), linked to a subject with cascading delete.

Attendance records and timetable entries build on top of these, resolving subject names/colors for display via the domain models in `features/attendance` and `features/timetable`.

### Notifications

`NotificationService` (in `features/notifications/`) schedules up to four local notifications per class occurrence:

1. 5 minutes **before** the class starts
2. 5 minutes **after** it starts
3. 5 minutes **after** it ends (first attendance nudge)
4. A **follow-up** a few hours later, cancelled automatically once attendance is marked

### OTA update pipeline

Lectra is distributed outside the Play Store, so it ships its own lightweight over-the-air update mechanism instead of relying on a store's auto-update:

- **`UpdateController`** checks this repo's GitHub Releases once a day, but only when the app is actually opened — there's no background/periodic checker, since a reminder app is only useful to update while someone's using it.
- **`UpdateService`** compares the latest release tag against the installed version and finds the attached `.apk` asset.
- **`UpdateInstaller`** downloads the APK with live progress reporting, verifies the download size matches before proceeding, and hands it to the system installer via `FileProvider`.
- **`UpdateDialog`** shows the prompt, download progress, and clear next steps if the install can't start (e.g. "Install unknown apps" not yet granted for Lectra).

### Releases

Every push of a `vX.Y.Z` tag triggers [`.github/workflows/release.yml`](.github/workflows/release.yml), which builds `flutter build apk --release` in CI and publishes it as a GitHub Release with the APK attached — no manual build/upload step required. To ship a new version:

```bash
# bump `version:` in pubspec.yaml first, then:
git add pubspec.yaml
git commit -m "Bump version to 0.2.0"
git push origin main

git tag v0.2.0
git push origin v0.2.0
```

Check the **Actions** tab to watch the build, then **Releases** for the published APK.

## Tech Stack

| Concern | Package |
|---|---|
| State management | `flutter_riverpod` |
| Routing | `go_router` |
| Local database | `drift` (SQLite) |
| Dynamic color | `dynamic_color` |
| Local notifications | `flutter_local_notifications`, `timezone` |
| Ads | `google_mobile_ads` |
| App/version info | `package_info_plus` |
| Networking | `http` |
| Paths | `path`, `path_provider` |
| Update download/install | `open_filex` |

## Contributing

Issues and pull requests are welcome. Please keep new code consistent with the existing feature-first structure (`model` → `repository` → `controller` → `screen`/`widgets`) and run `dart format` before submitting.
