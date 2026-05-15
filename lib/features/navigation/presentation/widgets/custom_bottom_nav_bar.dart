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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Icons.home_filled,
                label: 'Home',
                isSelected: currentIndex == 0,
                onTap: () => ref.read(navigationProvider.notifier).setIndex(0),
              ),
              _NavBarItem(
                icon: Icons.add_circle_outline,
                label: 'Entries',
                isSelected: currentIndex == 1,
                onTap: () => ref.read(navigationProvider.notifier).setIndex(1),
              ),
              _NavBarItem(
                icon: Icons.receipt_long,
                label: 'Ledger',
                isSelected: currentIndex == 2,
                onTap: () => ref.read(navigationProvider.notifier).setIndex(2),
              ),
              _NavBarItem(
                icon: Icons.notifications_outlined,
                label: 'Reminders',
                isSelected: currentIndex == 3,
                onTap: () => ref.read(navigationProvider.notifier).setIndex(3),
              ),
              _NavBarItem(
                icon: Icons.settings,
                label: 'Setting',
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF01565B) : Colors.transparent,
                shape: BoxShape.circle,
                border: isSelected ? Border.all(color: const Color(0xFFCFA63A), width: 1.5) : null,
              ),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFFCFA63A) : const Color(0xFF4D4635).withValues(alpha: 0.75),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inder(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? const Color(0xFF01565B) : const Color(0xFF4D4635).withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
