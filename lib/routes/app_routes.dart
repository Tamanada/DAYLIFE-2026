import 'package:flutter/material.dart';
import '../presentation/onboarding_screen/onboarding_screen.dart';
import '../presentation/main_shell/main_shell.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String main = '/main';

  static Map<String, WidgetBuilder> get routes => {
    onboarding: (context) => const OnboardingScreen(),
    main: (context) => const MainShell(),
  };
}
