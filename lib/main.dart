import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/providers.dart';
import 'screens/screens.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage service
  final storageService = StorageService();
  await storageService.init();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.init();
  // Request notification permissions early
  await notificationService.requestPermissions();
  
  runApp(TodoTogetherApp(
    storageService: storageService,
    notificationService: notificationService,
  ));
}

class TodoTogetherApp extends StatelessWidget {
  final StorageService storageService;
  final NotificationService notificationService;

  const TodoTogetherApp({
    super.key,
    required this.storageService,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        Provider<NotificationService>.value(value: notificationService),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(storageService)..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => GroupsProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => TasksProvider(storageService, notificationService),
        ),
      ],
      child: MaterialApp(
        title: 'TodoTogether',
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (auth.isAuthenticated) {
      return FutureBuilder<String?>(
        future: context.read<StorageService>().getLastGroupId(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          final lastGroupId = snapshot.data;
          if (lastGroupId != null) {
            return GroupScreen(groupId: lastGroupId);
          }
          return const HomeScreen();
        },
      );
    }

    return const LoginScreen();
  }
}
