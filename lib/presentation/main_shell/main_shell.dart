import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../services/star_service.dart';
import '../../services/supabase_service.dart';
import '../home_screen/home_screen.dart';
import '../dreams_screen/dreams_screen.dart';
import '../reflection_screen/reflection_screen.dart';
import '../profile_screen/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  DaylifeTab _currentTab = DaylifeTab.home;
  Map<String, dynamic>? _loginResult;

  @override
  void initState() {
    super.initState();
    _recordDailyLogin();
  }

  Future<void> _recordDailyLogin() async {
    try {
      final userId = SupabaseService.instance.getCurrentUserId();
      if (userId == null) return;
      final result = await StarService().recordDailyLogin(userId);
      if (mounted) setState(() => _loginResult = result);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentTab.index,
        children: [
          HomeScreen(loginResult: _loginResult),
          const DreamsScreen(),
          const ReflectionScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentTab: _currentTab,
        onTabSelected: (tab) => setState(() => _currentTab = tab),
      ),
    );
  }
}
