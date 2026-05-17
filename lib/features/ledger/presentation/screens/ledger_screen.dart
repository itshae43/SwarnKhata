import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarn_khata/core/models/transaction_model.dart';
import 'package:swarn_khata/features/ledger/providers/transaction_providers.dart';
import 'package:intl/intl.dart';

import '../../../parties/presentation/screens/party_detail_screen.dart';

class LedgerScreen extends ConsumerStatefulWidget {
  const LedgerScreen({super.key});

  @override
  ConsumerState<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends ConsumerState<LedgerScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Money', 'Diamond', 'Gold'];



  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFDFBF7),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              const SizedBox(height: 16),
              _buildFilterChips(),
              const SizedBox(height: 24),
              _buildSummaryCards(),
              const SizedBox(height: 32),
              _buildRecentActivityHeader(),
              const SizedBox(height: 16),
              _buildRecentActivityList(),
              const SizedBox(height: 80), // Padding for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search parties or transactions...',
          hintStyle: GoogleFonts.montserrat(
            color: Colors.grey[500],
            fontSize: 15,
          ),
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6B5800) : const Color(0xFFF5EFE6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF6B5800) : Colors.grey.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  filter,
                  style: GoogleFonts.montserrat(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'Total\nReceivables',
            amount: '₹ 12,45,000',
            subtitle: '+ 145g Fine Gold',
            icon: Icons.arrow_downward,
            iconColor: const Color(0xFFC62828),
            circleColor: const Color(0xFFFFF0F0),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            title: 'Total Payables\n',
            amount: '₹ 8,30,000',
            subtitle: '- 50g Fine Gold',
            icon: Icons.arrow_upward,
            iconColor: const Color(0xFF2852C6),
            circleColor: const Color(0xFFF0F4FF),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String amount,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color circleColor,
  }) {
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
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -16,
            top: -16,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circleColor,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                      height: 1.2,
                    ),
                  ),
                  Transform.rotate(
                    angle: icon == Icons.arrow_downward ? 0.8 : 0.8, // Adjust angle to match diagonal arrows
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                amount,
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "All Activity",
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivityList() {
    final transactionsAsync = ref.watch(transactionsStreamProvider);

    return transactionsAsync.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text('No recent activity'),
          ));
        }

        // Apply filters
        final filtered = transactions.where((tx) {
          if (_selectedFilter == 'All') return true;
          if (_selectedFilter == 'Money' && tx.metalType.isEmpty) return true;
          if (_selectedFilter == 'Gold' && tx.metalType == 'gold') return true;
          if (_selectedFilter == 'Diamond' && tx.metalType == 'diamond') return true;
          return false;
        }).toList();

        return Column(
          children: filtered.map((activity) {
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

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PartyDetailScreen(
                      party: PartyDetail(
                        id: activity.partyId,
                        name: activity.partyName,
                        type: 'Customer',
                        location: '',
                        initial: initial,
                        totalCashDue: '₹ 0',
                        cashDueLabel: 'Settled',
                        isCashYouOwe: false,
                        totalGoldDue: '0g',
                        goldDueLabel: 'Settled',
                        isGoldYouOwe: true,
                        phone: activity.partyPhone,
                        transactions: [], // Will be handled dynamically in PartyDetailScreen
                      ),
                    ),
                  ),
                );
              },
              child: Container(
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
                                width: 54,
                                height: 54,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF0EBE1),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  initial,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 22,
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
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      dateStr,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      timeStr,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 13,
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
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: color,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    middleRightLabel,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    typeLabel,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 13,
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
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
