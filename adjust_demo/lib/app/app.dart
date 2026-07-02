import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../constants/app_strings.dart';
import '../navigation/app_router.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

/// Root widget of the application.
///
/// Owns the [GoRouter] (built once from the [AuthProvider] so route guards can
/// react to auth changes) and rebuilds the [MaterialApp.router]'s theme when
/// the [ThemeProvider] changes.
class NovaApp extends StatefulWidget {
  const NovaApp({super.key});

  @override
  State<NovaApp> createState() => _NovaAppState();
}

class _NovaAppState extends State<NovaApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Build the router once with the (already-provided) AuthProvider so its
    // refreshListenable/redirect stay wired for the app's lifetime.
    _router = buildRouter(context.read<AuthProvider>());
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<ThemeProvider, ThemeMode>((t) => t.mode);

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}
