// lib/app.dart
//
// Dark, technical visual shell for the astrology-first experience.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'main.dart' show currentUserProvider;
import 'home_screen.dart';
import 'onboarding_screen.dart';

const _appTextFontFamily = 'AppText';

class AstroApp extends ConsumerWidget {
  const AstroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: '星巡',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const _RootRouter(),
    );
  }

  ThemeData _buildTheme() {
    const bg = Color(0xFF080A0D);
    const surface = Color(0xFF10141A);
    const panel = Color(0xFF151A21);
    const primary = Color(0xFF9BE7D4);
    const secondary = Color(0xFFB7C2FF);
    final scheme = const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: surface,
      onSurface: Color(0xFFECEFF4),
      error: Color(0xFFFF7B8A),
    );
    return ThemeData(
      useMaterial3: true,
      fontFamily: _appTextFontFamily,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      cardTheme: CardThemeData(
        elevation: 0,
        color: panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFF26303A)),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        foregroundColor: Color(0xFFECEFF4),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
          color: Color(0xFFECEFF4),
          fontFamily: _appTextFontFamily,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: const Color(0xFF07100E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: const BorderSide(color: Color(0xFF33414C)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF11161C),
        border: OutlineInputBorder(),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(height: 1.65),
        bodyLarge: TextStyle(height: 1.65),
      ).apply(fontFamily: _appTextFontFamily),
      dividerColor: const Color(0xFF26303A),
    );
  }
}

class _RootRouter extends ConsumerWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    return userAsync.when(
      loading: () => const _SplashScaffold(),
      error: (e, st) => Scaffold(body: Center(child: Text('読み込みエラー: $e'))),
      data: (user) =>
          user == null ? const OnboardingScreen() : const HomeScreen(),
    );
  }
}

class _SplashScaffold extends StatelessWidget {
  const _SplashScaffold();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
