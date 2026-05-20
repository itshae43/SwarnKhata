import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarn_khata/core/utils/responsive_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../auth/providers/auth_providers.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../entries/presentation/screens/entries_screen.dart';
import '../../../ledger/presentation/screens/ledger_screen.dart';
import '../../../reminders/presentation/screens/reminders_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../providers/navigation_provider.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/collapsible_sidebar.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isSidebarCollapsed = false;

  // Persistent GlobalKey to reparent the bodyContent smoothly on orientation change
  final GlobalKey _bodyKey = GlobalKey(debugLabel: 'main_body_content_key');

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOutCubic,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.02),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOutCubic,
      ),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _showLoginRequestDialog(Map<String, dynamic> request) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Login Request',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'User ${request['name']} (${request['phone']}) is trying to log in. Do you approve?',
            style: GoogleFonts.montserrat(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('login_requests')
                    .doc(request['id'])
                    .update({'status': 'declined'});
                Navigator.pop(context);
              },
              child: Text(
                'Decline',
                style: GoogleFonts.montserrat(color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('login_requests')
                    .doc(request['id'])
                    .update({'status': 'approved'});
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D4A1E),
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Approve',
                style: GoogleFonts.montserrat(),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationProvider);
    ref.listen<int>(navigationProvider, (previous, next) {
      if (previous != next) {
        _fadeController.forward(from: 0.0);
      }
    });

    ref.listen<AsyncValue<List<Map<String, dynamic>>>>(
        pendingLoginRequestsProvider, (previous, next) {
      final user = ref.read(currentUserProvider).value;
      if (user != null && user.role == 'admin') {
        final currentRequests = next.value ?? [];
        final previousRequests = previous?.value ?? [];

        final newRequests = currentRequests.where((req) =>
            req['status'] == 'pending' &&
            !previousRequests.any((prevReq) =>
                prevReq['id'] == req['id'] && prevReq['status'] == 'pending'));

        for (final req in newRequests) {
          _showLoginRequestDialog(req);
        }
      }
    });
    final isTablet = AppResponsive.isTablet(context);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final showSidebar = isTablet && isLandscape;

    Widget bodyContent = FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: IndexedStack(
            key: _bodyKey,
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
      ),
    );

    if (showSidebar) {
      bodyContent = Row(
        children: [
          CollapsibleSidebar(
            currentIndex: currentIndex,
            onTap: (index) {
              ref.read(navigationProvider.notifier).setIndex(index);
            },
            isCollapsed: _isSidebarCollapsed,
            onToggleCollapse: () {
              setState(() {
                _isSidebarCollapsed = !_isSidebarCollapsed;
              });
            },
          ),
          Expanded(child: bodyContent),
        ],
      );
    }

    return Scaffold(
      backgroundColor: isTablet ? const Color(0xFFFAF6EE) : const Color(0xFFFDFBF7),
      body: bodyContent,
      bottomNavigationBar: showSidebar ? null : const CustomBottomNavBar(),
    );
  }
}
