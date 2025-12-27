# TodoTogether

A collaborative task management app built with Flutter for Web and Android.

## Features

- **User Authentication**: Simple local authentication to get started quickly
- **Group Management**: Create groups and invite members with unique invite codes
- **Task Management**: Create, edit, and delete tasks with titles, descriptions, assignees, and reminder times
- **Task Completion**: Mark tasks as done with checkboxes - completed tasks are hidden from the main list
- **Smart Grouping**: Tasks are automatically grouped by reminder time (Today, Tomorrow, Upcoming, No Date)
- **Assignee Filtering**: Filter tasks by assignee to see individual responsibilities
- **Clean UI**: Light color scheme with Manus AI brand colors and DM Sans font

## Getting Started

### Prerequisites

- Flutter SDK (3.10.0 or higher)
- Dart SDK (3.10.0 or higher)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/todo_together.git
   cd todo_together
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   # For web
   flutter run -d chrome
   
   # For Android
   flutter run -d android
   ```

### Building for Production

```bash
# Build for web
flutter build web

# Build for Android
flutter build apk
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── task.dart
│   ├── user.dart
│   └── group.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   ├── groups_provider.dart
│   └── tasks_provider.dart
├── screens/                  # UI screens
│   ├── login_screen.dart
│   ├── home_screen.dart
│   └── group_screen.dart
├── services/                 # Services
│   └── storage_service.dart
├── theme/                    # App theming
│   └── app_theme.dart
└── widgets/                  # Reusable widgets
    ├── create_group_dialog.dart
    ├── join_group_dialog.dart
    ├── create_task_dialog.dart
    ├── edit_task_dialog.dart
    └── group_settings_sheet.dart
```

## Design

The app uses a clean, minimal design with:
- **Colors**: White (#FFFFFF), Gray (#F8F8F8), Black (#34322D)
- **Typography**: DM Sans font family
- **Components**: Material Design 3 with custom theming

## Data Storage

Data is stored locally using SharedPreferences. This means:
- Data persists across app restarts
- Data is device-specific (not synced across devices)
- No server or backend required

## License

MIT License
