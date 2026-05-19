import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:swarn_khata/core/models/session_model.dart';
import 'package:swarn_khata/core/utils/responsive_utils.dart';
import 'package:swarn_khata/features/auth/providers/auth_providers.dart';

class DeviceManagementScreen extends ConsumerWidget {
  const DeviceManagementScreen({super.key});

  IconData _getDeviceIcon(String os) {
    switch (os.toLowerCase()) {
      case 'android':
        return Icons.phone_android_rounded;
      case 'ios':
        return Icons.phone_iphone_rounded;
      case 'windows':
        return Icons.laptop_windows_rounded;
      case 'macos':
        return Icons.laptop_mac_rounded;
      case 'linux':
        return Icons.laptop_chromebook_rounded;
      case 'web':
        return Icons.language_rounded;
      default:
        return Icons.devices_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSessionsAsync = ref.watch(activeSessionsProvider);
    final user = ref.watch(authStateProvider).value;
    final isTablet = AppResponsive.isTablet(context);

    return Scaffold(
      backgroundColor: isTablet ? const Color(0xFFFAF6EE) : const Color(0xFFFDFBF7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: const Color(0xFF735C0F),
            size: isTablet ? 24 : 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Device Management',
          style: GoogleFonts.montserrat(
            color: const Color(0xFF1E1E1E),
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 22 : 18,
          ),
        ),
        centerTitle: false,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : activeSessionsAsync.when(
              data: (sessions) {
                if (sessions.isEmpty) {
                  return Center(
                    child: Text(
                      'No active sessions found.',
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        color: Colors.grey[600],
                      ),
                    ),
                  );
                }

                return FutureBuilder<String?>(
                  future: ref.read(sessionServiceProvider).getLocalSessionId(),
                  builder: (context, snapshot) {
                    final localSessionId = snapshot.data;

                    return ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 28.0 : 20.0,
                        vertical: 16.0,
                      ),
                      itemCount: sessions.length,
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        final isCurrent = session.id == localSessionId;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          padding: EdgeInsets.all(isTablet ? 20 : 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                            border: Border.all(
                              color: isCurrent
                                  ? const Color(0xFFDFBA6B).withOpacity(0.8)
                                  : Colors.grey.withOpacity(0.12),
                              width: isCurrent ? 2.0 : 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Device Icon
                              Container(
                                padding: EdgeInsets.all(isTablet ? 12 : 10),
                                decoration: BoxDecoration(
                                  color: isCurrent
                                      ? const Color(0xFFFFF3D0)
                                      : const Color(0xFFFAF6EE),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getDeviceIcon(session.os),
                                  color: const Color(0xFF8A7311),
                                  size: isTablet ? 26 : 22,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Device Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            session.deviceName,
                                            style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.bold,
                                              fontSize: isTablet ? 16 : 14,
                                              color: const Color(0xFF1E1E1E),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (isCurrent) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF01565B).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'Current',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF01565B),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'OS: ${session.os.toUpperCase()}',
                                      style: GoogleFonts.montserrat(
                                        fontSize: isTablet ? 13 : 11,
                                        color: Colors.grey[500],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Last active: ${DateFormat('dd MMM yyyy, hh:mm a').format(session.lastActiveAt)}',
                                      style: GoogleFonts.montserrat(
                                        fontSize: isTablet ? 13 : 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Logout Button
                              IconButton(
                                icon: const Icon(
                                  Icons.logout_rounded,
                                  color: Color(0xFFC62828),
                                ),
                                tooltip: isCurrent ? 'Sign Out' : 'Revoke Session',
                                onPressed: () => _confirmLogout(
                                  context,
                                  ref,
                                  session,
                                  user.uid,
                                  isCurrent,
                                  isTablet,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Color(0xFFD4B13B)),
                ),
              ),
              error: (err, stack) => Center(
                child: Text(
                  'Error loading sessions: $err',
                  style: GoogleFonts.montserrat(color: Colors.red),
                ),
              ),
            ),
    );
  }

  Future<void> _confirmLogout(
    BuildContext context,
    WidgetRef ref,
    SessionModel session,
    String userId,
    bool isCurrent,
    bool isTablet,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        ),
        title: Text(
          isCurrent ? 'Sign Out' : 'Logout Device',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 20 : 18,
          ),
        ),
        content: Text(
          isCurrent
              ? 'Are you sure you want to sign out from this device?'
              : 'Are you sure you want to log out the device "${session.deviceName}"? The app on that device will be locked.',
          style: GoogleFonts.montserrat(fontSize: isTablet ? 15 : 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.montserrat(
                color: Colors.grey[700],
                fontSize: isTablet ? 14 : 13,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 20 : 16,
                vertical: isTablet ? 12 : 8,
              ),
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: isTablet ? 14 : 13,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (isCurrent) {
        await ref.read(authNotifierProvider.notifier).signOut();
        if (context.mounted) {
          Navigator.pop(context); // Close Device Management Screen
        }
      } else {
        try {
          await ref
              .read(sessionServiceProvider)
              .deleteSession(userId, session.id)
              .timeout(const Duration(seconds: 2));
        } catch (_) {}
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logged out device: ${session.deviceName}'),
              backgroundColor: const Color(0xFF01565B),
            ),
          );
        }
      }
    }
  }
}
