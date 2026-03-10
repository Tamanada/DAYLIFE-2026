import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'core/app_export.dart';
import 'presentation/splash_screen/splash_screen.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const DaylifeApp());
}

class DaylifeApp extends StatelessWidget {
  const DaylifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'DAYLIFE',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.0),
              ),
              child: child!,
            );
          },
          home: const SplashScreen(),
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
