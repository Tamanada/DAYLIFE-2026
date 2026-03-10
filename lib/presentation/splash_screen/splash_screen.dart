import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), _navigate);
  }

  Future<void> _navigate() async {
    try {
      final userId = SupabaseService.instance.getCurrentUserId();
      if (userId == null) {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/onboarding');
        return;
      }

      final response = await SupabaseService.instance.client
          .from('user_profiles')
          .select('onboarding_completed')
          .eq('id', userId)
          .single();

      final onboardingCompleted =
          response['onboarding_completed'] as bool? ?? false;

      if (!mounted) return;
      if (onboardingCompleted) {
        Navigator.of(context).pushReplacementNamed('/main');
      } else {
        Navigator.of(context).pushReplacementNamed('/onboarding');
      }
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Column(
        children: [
          const Spacer(),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.hourglass_bottom_rounded,
                  size: 64,
                  color: Color(0xFFC0C0C0),
                ),
                const SizedBox(height: 16),
                Text(
                  'DAYLIFE',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFF5F5F0),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '30,000 Days',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFFCDB38B),
                      ),
                ),
              ],
            ),
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.only(bottom: 48),
            child: CircularProgressIndicator(
              color: Color(0xFFC0C0C0),
            ),
          ),
        ],
      ),
    );
  }
}
