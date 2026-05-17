import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../home/presentation/screens/home_screen.dart';
import '../../../entries/presentation/screens/entries_screen.dart';
import '../../../ledger/presentation/screens/ledger_screen.dart';
import '../../../reminders/presentation/screens/reminders_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../providers/navigation_provider.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void didUpdateWidget(MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Restart animation on tab change
    _fadeController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationProvider);

    // Using IndexedStack for perfect stability and state preservation
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: IndexedStack(
          index: currentIndex,
          children: const [
            HomeScreen(),
            EntriesScreen(),
            LedgerScreen(),
            RemindersScreen(),
            SettingsScreen(),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
