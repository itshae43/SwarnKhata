import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swarn_khata/core/models/user_model.dart';
import 'package:swarn_khata/features/auth/providers/auth_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // --- MOCK DATA ---
  // Balances will be fetched from Firestore in future iterations

  // Balances Data
  final String totalCash = '₹12,45,000';
  final String onlineBalance = '₹5,30,000';
  final String goldBalance = '450.25g';
  final String diamondBalance = '12.4 ct';

  // Today's Summary Data
  final String todayIn = '+₹45,000';
  final String todayOut = '-₹12,000';

  // Recent Transactions List
  final List<Map<String, dynamic>> recentTransactions = [
    {
      'icon': Icons.storefront_outlined,
      'iconBgColor': const Color(0xFFE8C73D),
      'iconColor': const Color(0xFF4A3E1F),
      'title': 'Gaurav Jewellers',
      'subtitle': 'Metal Deposit • 10:30 AM',
      'amount': '+ 50g Gold',
      'amountColor': const Color(0xFF8A7311),
      'lineColor': const Color(0xFF8A7311),
    },
    {
      'icon': Icons.point_of_sale_outlined,
      'iconBgColor': const Color(0xFFEBEBEB),
      'iconColor': const Color(0xFF555555),
      'title': 'Cash Sale',
      'subtitle': 'Retail • 09:15 AM',
      'amount': '+ ₹15,000',
      'amountColor': const Color(0xFF8A7311),
      'lineColor': const Color(0xFF8A7311),
    },
    {
      'icon': Icons.local_shipping_outlined,
      'iconBgColor': const Color(0xFFEBEBEB),
      'iconColor': const Color(0xFF555555),
      'title': 'Supplier Payment',
      'subtitle': 'Bank Transfer • Yesterday',
      'amount': '- ₹2,000',
      'amountColor': const Color(0xFFC62828),
      'lineColor': const Color(0xFFC62828),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFDFBF7), // Light cream background matching the image
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildBalancesGrid(),
              const SizedBox(height: 24),
              _buildTodaysSummary(),
              const SizedBox(height: 24),
              _buildRecentTransactions(),
              const SizedBox(height: 80), // Padding for bottom FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final userAsync = ref.watch(currentUserProvider);
    final userName = userAsync.when(
      data: (UserModel? u) => u?.fullName ?? 'Welcome',
      loading: () => 'Loading...',
      error: (_, __) => 'Welcome',
    );
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Row(
      children: [
        // Avatar with initial
        Container(
          padding: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF8A7311),
              width: 1.5,
            ),
          ),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFD4B13B),
            child: Text(
              initial,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Name
        Expanded(
          child: Text(
            userName,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6B5800),
              letterSpacing: -0.5,
            ),
          ),
        ),
        // Notification Icon
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_none_outlined,
            color: Color(0xFF4A3E1F),
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildBalancesGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildGridCard('Total Cash', totalCash, Icons.account_balance_wallet_outlined, const Color(0xFFF9F6ED), const Color(0xFFB08900)),
        _buildGridCard('Online Balance', onlineBalance, Icons.account_balance_outlined, const Color(0xFFF9F6ED), const Color(0xFFB08900)),
        _buildGridCard('Gold Balance', goldBalance, Icons.widgets_outlined, const Color(0xFFE8C73D), const Color(0xFF4A3E1F)),
        _buildGridCard('Diamond Balance', diamondBalance, Icons.diamond_outlined, const Color(0xFFE3EDF7), const Color(0xFF5B81A8)),
      ],
    );
  }

  Widget _buildGridCard(String title, String value, IconData icon, Color iconBgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Summary",
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.15)),
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
              // IN Section
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDFCF7), // VERY subtle cream tint
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8A7311),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.arrow_downward, size: 16, color: Color(0xFF757575)),
                                const SizedBox(width: 4),
                                Text("IN", style: GoogleFonts.montserrat(fontSize: 13, color: const Color(0xFF757575), fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(todayIn, style: GoogleFonts.montserrat(fontSize: 22, color: const Color(0xFF8A7311), fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Divider
              Container(width: 1, height: 60, color: Colors.grey.withOpacity(0.15)),
              // OUT Section
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF9F9), // VERY subtle red tint
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC62828),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.arrow_upward, size: 16, color: Color(0xFF757575)),
                                const SizedBox(width: 4),
                                Text("OUT", style: GoogleFonts.montserrat(fontSize: 13, color: const Color(0xFF757575), fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(todayOut, style: GoogleFonts.montserrat(fontSize: 22, color: const Color(0xFFC62828), fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recent Transactions",
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              "View All",
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8A7311),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            // Generating transactions dynamically from the list
            children: List.generate(recentTransactions.length, (index) {
              final tx = recentTransactions[index];
              return Column(
                children: [
                  _buildTransactionItem(
                    icon: tx['icon'] as IconData,
                    iconBgColor: tx['iconBgColor'] as Color,
                    iconColor: tx['iconColor'] as Color,
                    title: tx['title'] as String,
                    subtitle: tx['subtitle'] as String,
                    amount: tx['amount'] as String,
                    amountColor: tx['amountColor'] as Color,
                    lineColor: tx['lineColor'] as Color,
                    isFirst: index == 0,
                    isLast: index == recentTransactions.length - 1,
                  ),
                  if (index != recentTransactions.length - 1)
                    Divider(height: 1, thickness: 1, color: Colors.grey.withOpacity(0.1)),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String amount,
    required Color amountColor,
    required Color lineColor,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: lineColor,
              borderRadius: BorderRadius.only(
                topLeft: isFirst ? const Radius.circular(16) : Radius.zero,
                bottomLeft: isLast ? const Radius.circular(16) : Radius.zero,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    amount,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: amountColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

