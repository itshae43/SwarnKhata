import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swarn_khata/core/models/user_model.dart';
import 'package:swarn_khata/core/models/party_model.dart';
import 'package:swarn_khata/core/models/transaction_model.dart';
import 'package:swarn_khata/features/auth/providers/auth_providers.dart';
import 'package:swarn_khata/features/ledger/providers/transaction_providers.dart';
import 'package:swarn_khata/features/navigation/presentation/providers/navigation_provider.dart';
import 'package:swarn_khata/features/parties/providers/party_providers.dart';
import 'package:swarn_khata/features/parties/presentation/widgets/quick_add_party_bottom_sheet.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Balances will be fetched from Firestore in future iterations
  final String totalCash = '₹4,52,000';
  final String onlineBalance = '₹12,85,000';
  final String goldBalance = '4,250 g';
  final String diamondBalance = '15.5 ct';

  // Today's Summary Data (for Mobile View)
  final String todayIn = '+₹45,000';
  final String todayOut = '-₹12,000';

  // Search query state for Tablet Transaction Table
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    if (isTablet) {
      return _buildTabletHomeScreen();
    }

    // Existing mobile layout remains completely untouched!
    return Container(
      color: const Color(0xFFFDFBF7),
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

  // ==========================================
  // TABLET SCREEN LAYOUT (PIXEL-PERFECT REPLICATION)
  // ==========================================

  Widget _buildTabletHomeScreen() {
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final dateStr = DateFormat('EEEE, d MMMM').format(DateTime.now());

    return Container(
      color: const Color(0xFFFAF6EE), // Beautiful warm beige/cream background
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section (Date and New Entry button)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateStr,
                    style: GoogleFonts.inder(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF735C0F), // Olive-gold text matching the screenshot
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) => const Dialog(
                          backgroundColor: Colors.transparent,
                          child: _TabletQuickAddEntryDialog(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, color: Color(0xFF01565B), size: 18),
                    label: Text(
                      'New Entry',
                      style: GoogleFonts.inder(
                        color: const Color(0xFF01565B),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDFBA6B), // Gold background
                      elevation: 2,
                      shadowColor: Colors.black.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Summary Cards Grid (4 Cards Row)
              _buildTabletSummaryCards(),
              const SizedBox(height: 28),

              // Recent Transactions Table inside a beautifully styled Card
              _buildTabletTransactionsTable(transactionsAsync),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabletSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildTabletCard(
            label: 'TOTAL CASH',
            value: totalCash,
            accentColor: const Color(0xFF01565B),
            icon: Icons.payments_outlined,
            iconColor: const Color(0xFF01565B),
            iconBgColor: const Color(0xFFE8F8F0),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTabletCard(
            label: 'TOTAL UPI/RTGS',
            value: onlineBalance,
            accentColor: const Color(0xFF2E5BFF),
            icon: Icons.account_balance_rounded,
            iconColor: const Color(0xFF2E5BFF),
            iconBgColor: const Color(0xFFE6F0FA),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTabletCard(
            label: 'TOTAL GOLD',
            value: goldBalance,
            accentColor: const Color(0xFFDFBA6B),
            icon: Icons.widgets_rounded,
            iconColor: const Color(0xFF735C0F),
            iconBgColor: const Color(0xFFFFF9E6),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTabletCard(
            label: 'TOTAL DIAMOND',
            value: diamondBalance,
            accentColor: const Color(0xFF8EACCD),
            icon: Icons.diamond_rounded,
            iconColor: const Color(0xFF4F709C),
            iconBgColor: const Color(0xFFE3EDF7),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletCard({
    required String label,
    required String value,
    required Color accentColor,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5DEC9).withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          // Left colored accent strip
          Container(
            width: 4,
            color: accentColor,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.inder(
                          fontSize: 10,
                          color: const Color(0xFF5E543F).withOpacity(0.8),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: iconColor, size: 16),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        value,
                        style: GoogleFonts.inder(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF01565B).withOpacity(0.3)),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFF01565B),
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletTransactionsTable(AsyncValue<List<TransactionModel>> transactionsAsync) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5DEC9).withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table Title, Search Bar and Filter row
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transaction',
                  style: GoogleFonts.inder(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF01565B),
                  ),
                ),
                Row(
                  children: [
                    // Search Field
                    Container(
                      width: 240,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF6EE),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5DEC9)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        style: GoogleFonts.inder(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search ref...',
                          hintStyle: GoogleFonts.inder(color: const Color(0xFF5E543F).withOpacity(0.6), fontSize: 13),
                          prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF5E543F)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.only(bottom: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Filter Button
                    Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF6EE),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5DEC9)),
                      ),
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.filter_list_rounded, size: 18, color: Color(0xFF5E543F)),
                        label: Text(
                          'Filter',
                          style: GoogleFonts.inder(
                            color: const Color(0xFF5E543F),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: const Color(0xFFFAF6EE),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text('DATE', style: GoogleFonts.inder(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF5E543F)))),
                Expanded(flex: 3, child: Text('CUSTOMER NAME', style: GoogleFonts.inder(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF5E543F)))),
                Expanded(flex: 2, child: Text('CATEGORY', style: GoogleFonts.inder(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF5E543F)))),
                Expanded(flex: 2, child: Text('AMOUNT', style: GoogleFonts.inder(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF5E543F)))),
                Expanded(flex: 3, child: Text('NOTES', style: GoogleFonts.inder(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF5E543F)))),
              ],
            ),
          ),

          // Transaction Rows
          transactionsAsync.when(
            data: (transactions) {
              // Filter to get only today's transactions!
              final now = DateTime.now();
              final todayTransactions = transactions.where((t) {
                return t.date.year == now.year &&
                       t.date.month == now.month &&
                       t.date.day == now.day;
              }).toList();

              // Search query filter
              final filtered = todayTransactions.where((t) {
                final query = _searchQuery.toLowerCase().trim();
                if (query.isEmpty) return true;
                return t.partyName.toLowerCase().contains(query) ||
                       (t.notes?.toLowerCase().contains(query) ?? false) ||
                       t.metalType.toLowerCase().contains(query);
              }).toList();

              if (filtered.isEmpty) {
                return Container(
                  height: 160,
                  alignment: Alignment.center,
                  child: Text(
                    todayTransactions.isEmpty 
                        ? 'No transactions recorded today' 
                        : 'No matching transactions found',
                    style: GoogleFonts.inder(color: const Color(0xFF5E543F).withOpacity(0.6)),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                itemCount: filtered.length,
                separatorBuilder: (context, index) => const Divider(color: Color(0xFFF9F6EE), height: 1, thickness: 1),
                itemBuilder: (context, index) {
                  final t = filtered[index];
                  final isCredit = t.type == TransactionType.receipt || t.type == TransactionType.metalIn;
                  final dateStr = DateFormat('dd MMM, yyyy').format(t.date);
                  final timeStr = DateFormat('hh:mm a').format(t.date);
                  
                  // Customer Avatar color based on initials/name
                  final initial = t.partyName.isNotEmpty ? t.partyName[0].toUpperCase() : '?';
                  final avatarBgColor = _getAvatarColorForName(t.partyName);

                  // Category Pill
                  Widget categoryPill;
                  if (t.metalType.isEmpty) {
                    categoryPill = _buildCategoryPill('Cash', const Color(0xFFE8F8F0), const Color(0xFF00994C));
                  } else if (t.metalType == 'gold') {
                    categoryPill = _buildCategoryPill('Gold', const Color(0xFFFFF9E6), const Color(0xFFB38600));
                  } else {
                    categoryPill = _buildCategoryPill('Diamond', const Color(0xFFE6F0FA), const Color(0xFF0066CC));
                  }

                  // Amount
                  String amountStr = '';
                  final amountColor = isCredit ? const Color(0xFF01565B) : const Color(0xFFC62828);
                  final sign = isCredit ? '+ ' : '- ';

                  if (t.metalType.isEmpty) {
                    amountStr = '$sign₹ ${NumberFormat.decimalPattern('en_IN').format(t.cashAmount)}';
                  } else if (t.metalType == 'gold') {
                    amountStr = '$sign${t.metalWeight} g';
                  } else {
                    amountStr = '$sign${t.metalWeight} ct';
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    child: Row(
                      children: [
                        // DATE Column
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dateStr,
                                style: GoogleFonts.inder(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                timeStr,
                                style: GoogleFonts.inder(fontSize: 11, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),

                        // CUSTOMER NAME Column
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: avatarBgColor,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  initial,
                                  style: GoogleFonts.inder(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  t.partyName,
                                  style: GoogleFonts.inder(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // CATEGORY Column
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: categoryPill,
                          ),
                        ),

                        // AMOUNT Column
                        Expanded(
                          flex: 2,
                          child: Text(
                            amountStr,
                            style: GoogleFonts.inder(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: amountColor,
                            ),
                          ),
                        ),

                        // NOTES Column
                        Expanded(
                          flex: 3,
                          child: Text(
                            t.notes != null && t.notes!.trim().isNotEmpty ? t.notes! : '-',
                            style: GoogleFonts.inder(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
            error: (e, _) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Error loading transactions'))),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPill(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.inder(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Color _getAvatarColorForName(String name) {
    if (name.isEmpty) return const Color(0xFF01565B);
    final code = name.codeUnitAt(0);
    final colors = [
      const Color(0xFF2E5BFF),
      const Color(0xFF8EACCD),
      const Color(0xFF01565B),
      const Color(0xFFDFBA6B),
      const Color(0xFFCFA63A),
    ];
    return colors[code % colors.length];
  }

  // ==========================================
  // MOBILE SCREEN LAYOUT (UNCHANGED CORE ELEMENTS)
  // ==========================================

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
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDFCF7),
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
              Container(width: 1, height: 60, color: Colors.grey.withOpacity(0.15)),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF9F9),
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
    final transactionsAsync = ref.watch(transactionsStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recent Activity (Today)",
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4A3E1F),
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(navigationProvider.notifier).setIndex(2); // Redirect to Ledger
              },
              child: Text(
                "View All",
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF8A7311),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        transactionsAsync.when(
          data: (transactions) {
            // Filter to get only today's transactions!
            final now = DateTime.now();
            final todayTransactions = transactions.where((t) {
              return t.date.year == now.year &&
                     t.date.month == now.month &&
                     t.date.day == now.day;
            }).toList();

            if (todayTransactions.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Center(
                  child: Text(
                    'No transactions recorded today',
                    style: GoogleFonts.montserrat(color: Colors.grey),
                  ),
                ),
              );
            }

            final recent = todayTransactions.take(4).toList();

            return Column(
              children: recent.map((activity) {
                final isCredit = activity.type == TransactionType.receipt || activity.type == TransactionType.metalIn;
                final color = isCredit ? const Color(0xFF2852C6) : const Color(0xFFC62828);
                final typeLabel = isCredit ? 'In' : 'Out';
                
                String topRightLabel = '';
                String middleRightLabel = '';
                
                if (activity.metalType.isEmpty) {
                  topRightLabel = activity.paymentMode.name.toUpperCase();
                  middleRightLabel = '₹ ${NumberFormat.decimalPattern('en_IN').format(activity.cashAmount)}';
                } else if (activity.metalType == 'gold') {
                  topRightLabel = 'Gold (${activity.metalPurity}%)';
                  middleRightLabel = '${activity.metalWeight}g';
                } else if (activity.metalType == 'diamond') {
                  topRightLabel = 'Diamond(${activity.metalWeight}ct)';
                  middleRightLabel = activity.metalPurity;
                }

                final initial = activity.partyName.isNotEmpty ? activity.partyName[0].toUpperCase() : '?';
                final dateStr = DateFormat('dd MMM yyyy').format(activity.date);
                final timeStr = DateFormat('hh:mm a').format(activity.date);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: 4,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF0EBE1),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    initial,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF6B5800),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        activity.partyName,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        dateStr,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        timeStr,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      topRightLabel,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: color,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      middleRightLabel,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      typeLabel,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: color,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error loading transactions')),
        ),
      ],
    );
  }
}

// ==========================================
// TABLET QUICK ADD DIALOG & FORMATTERS
// ==========================================

class _TabletQuickAddEntryDialog extends ConsumerStatefulWidget {
  const _TabletQuickAddEntryDialog({super.key});

  @override
  ConsumerState<_TabletQuickAddEntryDialog> createState() => _TabletQuickAddEntryDialogState();
}

class _TabletQuickAddEntryDialogState extends ConsumerState<_TabletQuickAddEntryDialog> {
  String _transactionType = 'IN';
  String _category = 'Money'; // Money, Gold, Diamond
  String _paymentMode = 'Cash'; // Cash, UPI, RTGS
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _partyController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _purityController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _caratController = TextEditingController();
  final TextEditingController _piecesController = TextEditingController();
  final FocusNode _partyFocusNode = FocusNode();

  PartyModel? _selectedParty;
  String? _pendingPartyId;
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _partyController.dispose();
    _notesController.dispose();
    _purityController.dispose();
    _weightController.dispose();
    _caratController.dispose();
    _piecesController.dispose();
    _partyFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parties = ref.watch(partiesStreamProvider).value ?? [];
    
    if (_pendingPartyId != null && parties.isNotEmpty) {
      try {
        final party = parties.firstWhere((p) => p.id == _pendingPartyId);
        _pendingPartyId = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _selectedParty = party;
              _partyController.text = party.name;
            });
          }
        });
      } catch (_) {}
    }

    return Container(
      width: 620,
      constraints: const BoxConstraints(maxHeight: 750),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6EE), // Sleek warm beige background matching the screenshot
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5DEC9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Row: Title & Pickers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Add Entry',
                      style: GoogleFonts.inder(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF01565B), // Deep teal
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Record transaction details.',
                      style: GoogleFonts.inder(
                        fontSize: 13,
                        color: const Color(0xFF5E543F).withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildDateTimePicker(
                      icon: Icons.calendar_today_outlined,
                      text: DateFormat('dd MMM yyyy').format(_selectedDate),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildDateTimePicker(
                      icon: Icons.access_time_outlined,
                      text: _selectedTime.format(context),
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime,
                        );
                        if (picked != null) {
                          setState(() => _selectedTime = picked);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // IN / OUT Toggle
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF4EDE4),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTransactionTypeButton(
                      title: 'IN (Receive)',
                      icon: Icons.arrow_downward,
                      selectedColor: const Color(0xFF01565B),
                      isSelected: _transactionType == 'IN',
                      onTap: () => setState(() => _transactionType = 'IN'),
                    ),
                  ),
                  Expanded(
                    child: _buildTransactionTypeButton(
                      title: 'OUT (Give)',
                      icon: Icons.arrow_upward,
                      selectedColor: const Color(0xFFC62828),
                      isSelected: _transactionType == 'OUT',
                      onTap: () => setState(() => _transactionType = 'OUT'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Party / Customer Selector Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Party / Customer',
                  style: GoogleFonts.inder(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF5E543F),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final newId = await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const QuickAddPartyBottomSheet(),
                    );
                    if (newId != null && newId is String) {
                      setState(() => _pendingPartyId = newId);
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFDFBA6B)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.add, size: 16, color: Color(0xFF735C0F)),
                        const SizedBox(width: 4),
                        Text(
                          'Add New',
                          style: GoogleFonts.inder(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF735C0F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildPartyAutocomplete(),
            const SizedBox(height: 20),

            // Category Toggle
            Text(
              'Category',
              style: GoogleFonts.inder(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5E543F),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF4EDE4),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _buildCategoryButton('Money'),
                  _buildCategoryButton('Gold'),
                  _buildCategoryButton('Diamond'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Dynamic Form Fields based on Category
            if (_category == 'Money') ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5DEC9).withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Mode',
                      style: GoogleFonts.inder(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5E543F),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildPaymentModeChip('Cash'),
                        const SizedBox(width: 12),
                        _buildPaymentModeChip('UPI'),
                        const SizedBox(width: 12),
                        _buildPaymentModeChip('RTGS'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Amount',
                      style: GoogleFonts.inder(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5E543F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _IndianCurrencyFormatter(),
                      ],
                      style: GoogleFonts.inder(fontSize: 18, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: GoogleFonts.inder(color: Colors.grey.shade300, fontSize: 18),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4EDE4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('₹', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF735C0F))),
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFDFBA6B)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (_category == 'Gold') ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Purity %',
                          style: GoogleFonts.inder(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF5E543F)),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _purityController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.right,
                          style: GoogleFonts.inder(fontSize: 15),
                          decoration: InputDecoration(
                            hintText: '99.5',
                            hintStyle: GoogleFonts.inder(color: Colors.grey.shade400, fontSize: 15),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('%', style: GoogleFonts.inder(fontSize: 16, color: Colors.grey.shade600)),
                                ],
                              ),
                            ),
                            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFDFBA6B)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weight (g)',
                          style: GoogleFonts.inder(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF5E543F)),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _weightController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.right,
                          style: GoogleFonts.inder(fontSize: 15),
                          decoration: InputDecoration(
                            hintText: '0.00',
                            hintStyle: GoogleFonts.inder(color: Colors.grey.shade400, fontSize: 15),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('g', style: GoogleFonts.inder(fontSize: 16, color: Colors.grey.shade600)),
                                ],
                              ),
                            ),
                            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFDFBA6B)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ] else if (_category == 'Diamond') ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CARAT (CT)',
                          style: GoogleFonts.inder(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF5E543F)),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _caratController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inder(fontSize: 16, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: '0.00',
                            hintStyle: GoogleFonts.inder(color: Colors.grey.shade400, fontSize: 16, fontWeight: FontWeight.w600),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFDFBA6B)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PIECES',
                          style: GoogleFonts.inder(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF5E543F)),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _piecesController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inder(fontSize: 16, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: '0',
                            hintStyle: GoogleFonts.inder(color: Colors.grey.shade400, fontSize: 16, fontWeight: FontWeight.w600),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFDFBA6B)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),

            // Particulars / Notes
            Text(
              'Particulars / Notes',
              style: GoogleFonts.inder(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5E543F),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 2,
              style: GoogleFonts.inder(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Add details about the transaction...',
                hintStyle: GoogleFonts.inder(color: Colors.grey.shade500),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFDFBA6B)),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFFF4EDE4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inder(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveTransaction,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFFDFBA6B), // Gold
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF01565B)),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check, color: Color(0xFF01565B), size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Save Entry',
                                style: GoogleFonts.inder(
                                  color: const Color(0xFF01565B),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimePicker({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5DEC9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF5E543F)),
            const SizedBox(width: 6),
            Text(
              text,
              style: GoogleFonts.inder(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5E543F),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTypeButton({
    required String title,
    required IconData icon,
    required Color selectedColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? const Color(0xFFE5DEC9) : Colors.transparent,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? selectedColor : const Color(0xFF5E543F), size: 16),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.inder(
                color: isSelected ? selectedColor : const Color(0xFF5E543F),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String categoryName) {
    final isSelected = _category == categoryName;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _category = categoryName),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              categoryName,
              style: GoogleFonts.inder(
                color: isSelected ? const Color(0xFF01565B) : const Color(0xFF5E543F),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentModeChip(String mode) {
    final isSelected = _paymentMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _paymentMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF9E6) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFDFBA6B) : const Color(0xFFE5DEC9),
          ),
        ),
        child: Text(
          mode,
          style: GoogleFonts.inder(
            color: isSelected ? const Color(0xFF735C0F) : const Color(0xFF5E543F),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildPartyAutocomplete() {
    return LayoutBuilder(
      builder: (context, constraints) => RawAutocomplete<PartyModel>(
        focusNode: _partyFocusNode,
        textEditingController: _partyController,
        optionsBuilder: (TextEditingValue textEditingValue) {
          final query = textEditingValue.text.trim().toLowerCase();
          final parties = ref.read(partiesStreamProvider).value ?? [];
          
          if (query.isEmpty) {
            final recent = parties.toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
            return recent.take(5);
          }
          
          final matches = parties.where((party) {
            return party.name.toLowerCase().contains(query) || party.phone.contains(query);
          }).toList();
          
          return matches;
        },
        displayStringForOption: (PartyModel option) => option.name,
        onSelected: (PartyModel selection) {
          setState(() => _selectedParty = selection);
        },
        fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
          return TextField(
            controller: textEditingController,
            focusNode: focusNode,
            style: GoogleFonts.inder(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search party name or phone...',
              hintStyle: GoogleFonts.inder(color: Colors.grey.shade500),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF5E543F), size: 18),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDFBA6B)),
              ),
              suffixIcon: _selectedParty != null || textEditingController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        textEditingController.clear();
                        setState(() => _selectedParty = null);
                      },
                    )
                  : null,
            ),
            onSubmitted: (String value) {
              onFieldSubmitted();
            },
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              clipBehavior: Clip.antiAlias,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 200, maxWidth: constraints.maxWidth),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final option = options.elementAt(index);

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFF4EDE4),
                        radius: 16,
                        child: Text(
                          option.name.isNotEmpty ? option.name[0].toUpperCase() : '?',
                          style: GoogleFonts.inder(color: const Color(0xFF735C0F), fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      title: _buildHighlightText(option.name, _partyController.text),
                      subtitle: option.phone.isNotEmpty ? Text(option.phone, style: GoogleFonts.inder(fontSize: 11)) : null,
                      dense: true,
                      onTap: () => onSelected(option),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHighlightText(String text, String query) {
    if (query.isEmpty) return Text(text, style: GoogleFonts.inder(fontWeight: FontWeight.w500));
    final matchIndex = text.toLowerCase().indexOf(query.toLowerCase());
    if (matchIndex == -1) return Text(text, style: GoogleFonts.inder(fontWeight: FontWeight.w500));
    return RichText(
      text: TextSpan(
        text: text.substring(0, matchIndex),
        style: GoogleFonts.inder(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 13),
        children: [
          TextSpan(
            text: text.substring(matchIndex, matchIndex + query.length),
            style: GoogleFonts.inder(color: const Color(0xFFDFBA6B), fontWeight: FontWeight.bold, fontSize: 13),
          ),
          TextSpan(
            text: text.substring(matchIndex + query.length),
            style: GoogleFonts.inder(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTransaction() async {
    if (_selectedParty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a party')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Determine TransactionType
      TransactionType tType = TransactionType.sale; // default
      if (_transactionType == 'IN') {
        if (_category == 'Money') tType = TransactionType.receipt;
        else tType = TransactionType.metalIn;
      } else {
        if (_category == 'Money') tType = TransactionType.payment;
        else tType = TransactionType.metalOut;
      }

      // Determine PaymentMode
      PaymentMode pMode = PaymentMode.cash;
      if (_category == 'Money') {
        if (_paymentMode == 'Cash') pMode = PaymentMode.cash;
        else if (_paymentMode == 'UPI') pMode = PaymentMode.upi;
        else if (_paymentMode == 'RTGS') pMode = PaymentMode.rtgs;
      } else {
        pMode = PaymentMode.metal;
      }

      // Parse values
      double cashAmt = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;
      double metalWt = 0.0;
      if (_category == 'Gold') metalWt = double.tryParse(_weightController.text) ?? 0.0;
      if (_category == 'Diamond') metalWt = double.tryParse(_caratController.text) ?? 0.0;
      
      String metalP = '';
      if (_category == 'Gold') metalP = _purityController.text.trim();
      if (_category == 'Diamond') metalP = '${_piecesController.text.trim()} p';

      final date = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day,
        _selectedTime.hour, _selectedTime.minute,
      );

      final success = await ref.read(transactionNotifierProvider.notifier).createTransaction(
        partyId: _selectedParty!.id,
        partyName: _selectedParty!.name,
        partyPhone: _selectedParty!.phone,
        type: tType,
        paymentMode: pMode,
        cashAmount: cashAmt,
        metalType: _category == 'Money' ? '' : _category.toLowerCase(),
        metalWeight: metalWt,
        metalPurity: metalP,
        notes: _notesController.text.trim(),
        date: date,
      );

      if (success && mounted) {
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quick Entry saved successfully')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save entry')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred while saving')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _IndianCurrencyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    try {
      int value = int.parse(cleanText);
      final formatter = NumberFormat.decimalPattern('en_IN');
      String formattedText = formatter.format(value);

      return newValue.copyWith(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    } catch (e) {
      return oldValue;
    }
  }
}
