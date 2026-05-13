import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swarn_khata/features/auth/providers/auth_providers.dart';
import 'package:swarn_khata/core/models/user_model.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Container(
      color: const Color(0xFFFDFBF7),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── HEADER ─────────────────────────────────────────
              Text(
                'Settings',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 24),

              // ─── PROFILE CARD ────────────────────────────────────
              userAsync.when(
                data: (UserModel? user) => _buildProfileCard(
                    user?.fullName ?? 'User',
                    user?.businessName ?? '',
                    user?.email ?? user?.phone ?? ''),
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Color(0xFFD4B13B)),
                  ),
                ),
                error: (e, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),

              // ─── SECTION: ACCOUNT ────────────────────────────────
              _sectionLabel('Account'),
              const SizedBox(height: 12),
              _buildSettingsTile(
                icon: Icons.person_outline_rounded,
                label: 'Edit Profile',
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: Icons.lock_outline_rounded,
                label: 'Change Password',
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: Icons.notifications_none_outlined,
                label: 'Notifications',
                onTap: () {},
              ),
              const SizedBox(height: 20),

              // ─── SECTION: BUSINESS ───────────────────────────────
              _sectionLabel('Business'),
              const SizedBox(height: 12),
              _buildSettingsTile(
                icon: Icons.store_outlined,
                label: 'Business Details',
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: Icons.currency_rupee_outlined,
                label: 'Currency & Units',
                onTap: () {},
              ),
              const SizedBox(height: 20),

              // ─── SECTION: SUPPORT ────────────────────────────────
              _sectionLabel('Support'),
              const SizedBox(height: 12),
              _buildSettingsTile(
                icon: Icons.help_outline_rounded,
                label: 'Help & FAQ',
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                onTap: () {},
              ),
              const SizedBox(height: 28),

              // ─── SIGN OUT BUTTON ─────────────────────────────────
              _buildSignOutButton(context, ref),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(
      String fullName, String businessName, String contact) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD4B13B), Color(0xFF8A7311)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName.isEmpty ? 'User' : fullName,
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E1E1E),
                  ),
                ),
                if (businessName.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    businessName,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: const Color(0xFF8A7311),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  contact,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.edit_outlined, color: Colors.grey[400], size: 20),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.montserrat(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.grey[500],
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3D0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF8A7311), size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1E1E1E),
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text('Sign Out',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
              content: Text('Are you sure you want to sign out?',
                  style: GoogleFonts.montserrat(fontSize: 14)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text('Cancel',
                      style: GoogleFonts.montserrat(color: Colors.grey[700])),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC62828),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Sign Out',
                      style: GoogleFonts.montserrat(color: Colors.white)),
                ),
              ],
            ),
          );
          if (confirmed == true) {
            await ref.read(authNotifierProvider.notifier).signOut();
          }
        },
        icon: const Icon(Icons.logout_rounded, color: Color(0xFFC62828)),
        label: Text(
          'Sign Out',
          style: GoogleFonts.montserrat(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFC62828),
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFC62828)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
