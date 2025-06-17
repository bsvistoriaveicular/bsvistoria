import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bs_vistoria_veicular/config/theme/app_theme.dart';
import 'package:bs_vistoria_veicular/config/routes/app_router.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:bs_vistoria_veicular/core/providers/notification_provider.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://fjrsvuhdqtbhrvyqkznf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZqcnN2dWhkcXRiaHJ2eXFrem5mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAxMjc2ODQsImV4cCI6MjA2NTcwMzY4NH0.1Dxsqr3-kQkhxl84igjYMcZEfCv1Q9_glVZSmC2WM9Y',
  );

  // Configuração das notificações locais
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings(
          'app_icon'); // certifique-se de ter um ícone chamado 'app_icon.png' na pasta android/app/src/main/res/drawable/

  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(
    ProviderScope(
      overrides: [
        flutterLocalNotificationsPluginProvider
            .overrideWithValue(flutterLocalNotificationsPlugin),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'B&S Vistoria Veicular',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
