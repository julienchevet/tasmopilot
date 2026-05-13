import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    // ProviderScope is required for Riverpod
    const ProviderScope(
      child: TasmopilotApp(),
    ),
  );
}

class TasmopilotApp extends ConsumerWidget {
  const TasmopilotApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Tasmopilot',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Uses system dark/light mode preference
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
