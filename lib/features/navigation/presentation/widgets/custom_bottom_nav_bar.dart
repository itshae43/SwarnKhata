import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/navigation_provider.dart';

class CustomBottomNavBar extends ConsumerWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 76,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isSelected: currentIndex == 0,
                onTap: () => ref.read(navigationProvider.notifier).setIndex(0),
              ),
              _NavBarItem(
                icon: Icons.add_box_rounded,
                label: 'Entries',
                isSelected: currentIndex == 1,
                onTap: () => ref.read(navigationProvider.notifier).setIndex(1),
              ),
              _NavBarItem(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Ledger',
                isSelected: currentIndex == 2,
                onTap: () => ref.read(navigationProvider.notifier).setIndex(2),
              ),
              _NavBarItem(
                icon: Icons.notifications_active_rounded,
                label: 'Reminders',
                isSelected: currentIndex == 3,
                onTap: () => ref.read(navigationProvider.notifier).setIndex(3),
              ),
              _NavBarItem(
                icon: Icons.settings_rounded,
                label: 'Settings',
                isSelected: currentIndex == 4,
                onTap: () => ref.read(navigationProvider.notifier).setIndex(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Animated background circle
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutBack,
                  width: isSelected ? 42 : 0,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF01565B),
                    shape: BoxShape.circle,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF01565B).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [],
                  ),
                ),
                // Icon with scale and color animation
                AnimatedScale(
                  scale: isSelected ? 1.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      icon,
                      color: isSelected 
                          ? const Color(0xFFCFA63A) 
                          : const Color(0xFF4D4635).withOpacity(0.6),
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Label with style animation
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              style: GoogleFonts.inder(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected 
                    ? const Color(0xFF01565B) 
                    : const Color(0xFF4D4635).withOpacity(0.6),
                letterSpacing: isSelected ? 0.3 : 0,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
