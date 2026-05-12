import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../home/presentation/screens/home_screen.dart';
import '../../../entries/presentation/screens/entries_screen.dart';
import '../../../ledger/presentation/screens/ledger_screen.dart';
import '../../../parties/presentation/screens/parties_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../providers/navigation_provider.dart';
import '../widgets/custom_bottom_nav_bar.dart';

import '../../../entries/presentation/widgets/new_entry_bottom_sheet.dart';
import '../../../parties/presentation/screens/add_party_screen.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationProvider);

    final screens = [
      const HomeScreen(),
      const EntriesScreen(),
      const LedgerScreen(),
      const PartiesScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      appBar: currentIndex != 0 
          ? AppBar(
              title: Image.asset(
                'assets/images/logo.png',
                height: 32,
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
            )
          : null,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: screens[currentIndex],
      ),
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddPartyScreen()),
                );
              },
              backgroundColor: const Color(0xFF8A7311),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.add, color: Colors.white, size: 32),
            )
          : null,
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
