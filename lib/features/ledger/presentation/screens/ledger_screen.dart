import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:swarn_khata/core/models/party_model.dart';
import 'package:swarn_khata/core/models/transaction_model.dart';
import 'package:swarn_khata/features/parties/providers/party_providers.dart';
import 'package:swarn_khata/features/ledger/providers/transaction_providers.dart';
import '../../../parties/presentation/screens/party_detail_screen.dart';

class LedgerScreen extends ConsumerStatefulWidget {
  const LedgerScreen({super.key});

  @override
  ConsumerState<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends ConsumerState<LedgerScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Money', 'Diamond', 'Gold'];
  
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
    final partiesAsync = ref.watch(partiesStreamProvider);
    final transactionsAsync = ref.watch(transactionsStreamProvider);

    return Container(
      color: const Color(0xFFFDFBF7),
      child: SafeArea(
        child: partiesAsync.when(
          data: (parties) {
            final transactions = transactionsAsync.value ?? [];
            
            // Apply Search Query
            final query = _searchQuery.toLowerCase().trim();
            
            // Sort parties alphabetically by name (A to Z)
            final List<PartyModel> sortedParties = List.from(parties)
              ..sort((a, b) => a.name.trim().toLowerCase().compareTo(b.name.trim().toLowerCase()));

            // Filter by search query
            List<PartyModel> filteredParties = sortedParties.where((p) {
              if (query.isEmpty) return true;
              return p.name.toLowerCase().contains(query) ||
                  p.phone.toLowerCase().contains(query);
            }).toList();

            // Filter by selected category balance
            if (_selectedFilter == 'Money') {
              filteredParties = filteredParties.where((p) => p.cashBalance != 0).toList();
            } else if (_selectedFilter == 'Gold') {
              filteredParties = filteredParties.where((p) => p.goldBalanceGrams != 0).toList();
            } else if (_selectedFilter == 'Diamond') {
              filteredParties = filteredParties.where((p) => p.diamondBalanceCarats != 0).toList();
            }

            // Calculate dynamic summary values from all parties (reflecting total outstanding positions)
            double totalCashReceivable = 0;
            double totalGoldReceivable = 0;
            double totalCashPayable = 0;
            double totalGoldPayable = 0;

            for (final p in parties) {
              if (p.cashBalance > 0) {
                totalCashReceivable += p.cashBalance;
              } else if (p.cashBalance < 0) {
                totalCashPayable += p.cashBalance.abs();
              }

              if (p.goldBalanceGrams > 0) {
                totalGoldReceivable += p.goldBalanceGrams;
              } else if (p.goldBalanceGrams < 0) {
                totalGoldPayable += p.goldBalanceGrams.abs();
              }
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32.0 : 16.0,
                vertical: isTablet ? 24.0 : 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(isTablet),
                  SizedBox(height: isTablet ? 24 : 16),
                  _buildFilterChips(isTablet),
                  SizedBox(height: isTablet ? 32 : 24),
                  _buildDynamicSummaryCards(
                    isTablet: isTablet,
                    totalCashReceivable: totalCashReceivable,
                    totalGoldReceivable: totalGoldReceivable,
                    totalCashPayable: totalCashPayable,
                    totalGoldPayable: totalGoldPayable,
                  ),
                  SizedBox(height: isTablet ? 48 : 32),
                  _buildRecentActivityHeader(isTablet),
                  SizedBox(height: isTablet ? 24 : 16),
                  _buildPartiesList(filteredParties, isTablet, transactions),
                  const SizedBox(height: 80), // Padding for bottom nav
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error loading ledger: $e')),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 32 : 24),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: GoogleFonts.montserrat(
          fontSize: isTablet ? 18 : 15,
        ),
        decoration: InputDecoration(
          hintText: 'Search customers by name or phone...',
          hintStyle: GoogleFonts.montserrat(
            color: Colors.grey[500],
            fontSize: isTablet ? 18 : 15,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 12),
            child: Icon(Icons.search, color: Colors.grey[600], size: isTablet ? 28 : 24),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right: isTablet ? 16 : 12),
                    child: Icon(Icons.clear, color: Colors.grey[600], size: isTablet ? 24 : 20),
                  ),
                )
              : null,
          suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24 : 20,
            vertical: isTablet ? 18 : 14,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isTablet) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: EdgeInsets.only(right: isTablet ? 16.0 : 12.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 28 : 20,
                  vertical: isTablet ? 12 : 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6B5800) : const Color(0xFFF5EFE6),
                  borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF6B5800) : Colors.grey.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  filter,
                  style: GoogleFonts.montserrat(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: isTablet ? 18 : 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDynamicSummaryCards({
    required bool isTablet,
    required double totalCashReceivable,
    required double totalGoldReceivable,
    required double totalCashPayable,
    required double totalGoldPayable,
  }) {
    final formatCurrency = NumberFormat.decimalPattern('en_IN');
    final cashReceivableStr = '₹ ${formatCurrency.format(totalCashReceivable)}';
    final goldReceivableStr = '+ ${totalGoldReceivable.toStringAsFixed(3)}g Fine Gold';

    final cashPayableStr = '₹ ${formatCurrency.format(totalCashPayable)}';
    final goldPayableStr = '- ${totalGoldPayable.toStringAsFixed(3)}g Fine Gold';

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            isTablet: isTablet,
            title: 'Total\nReceivables',
            amount: cashReceivableStr,
            subtitle: goldReceivableStr,
            icon: Icons.arrow_downward,
            iconColor: const Color(0xFF2852C6),
            circleColor: const Color(0xFFF0F4FF),
          ),
        ),
        SizedBox(width: isTablet ? 20 : 12),
        Expanded(
          child: _buildSummaryCard(
            isTablet: isTablet,
            title: 'Total Payables\n',
            amount: cashPayableStr,
            subtitle: goldPayableStr,
            icon: Icons.arrow_upward,
            iconColor: const Color(0xFFC62828),
            circleColor: const Color(0xFFFFF0F0),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required bool isTablet,
    required String title,
    required String amount,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color circleColor,
  }) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
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
            right: isTablet ? -20 : -16,
            top: isTablet ? -20 : -16,
            child: Container(
              width: isTablet ? 100 : 80,
              height: isTablet ? 100 : 80,
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
                      fontSize: isTablet ? 17 : 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                      height: 1.2,
                    ),
                  ),
                  Transform.rotate(
                    angle: 0.8,
                    child: Icon(icon, color: iconColor, size: isTablet ? 26 : 20),
                  ),
                ],
              ),
              SizedBox(height: isTablet ? 20 : 16),
              Text(
                amount,
                style: GoogleFonts.montserrat(
                  fontSize: isTablet ? 26 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.montserrat(
                  fontSize: isTablet ? 16 : 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityHeader(bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Customers Ledger",
          style: GoogleFonts.montserrat(
            fontSize: isTablet ? 24 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPartiesList(List<PartyModel> filteredParties, bool isTablet, List<TransactionModel> transactions) {
    if (filteredParties.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: isTablet ? 80 : 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No customers found',
                style: GoogleFonts.montserrat(
                  fontSize: isTablet ? 18 : 16,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: filteredParties.map((party) => _buildPartyCard(party, isTablet, transactions)).toList(),
    );
  }

  Widget _buildPartyCard(PartyModel party, bool isTablet, List<TransactionModel> transactions) {
    final partyTxns = transactions.where((t) => t.partyId == party.id).toList();
    final txnCount = partyTxns.length;

    Color leftBorderColor = const Color(0xFFDFBA6B); // Premium brand gold
    if (party.cashBalance > 0 || party.goldBalanceGrams > 0 || party.diamondBalanceCarats > 0) {
      leftBorderColor = const Color(0xFF2852C6); // Receivable Blue
    } else if (party.cashBalance < 0 || party.goldBalanceGrams < 0 || party.diamondBalanceCarats < 0) {
      leftBorderColor = const Color(0xFFC62828); // Payable Red
    }

    final initial = party.name.isNotEmpty ? party.name[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PartyDetailScreen(
              party: _getPartyDetail(party),
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.12)),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: isTablet ? 6 : 4,
                decoration: BoxDecoration(
                  color: leftBorderColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isTablet ? 20 : 16),
                    bottomLeft: Radius.circular(isTablet ? 20 : 16),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
                  child: Row(
                    children: [
                      Container(
                        width: isTablet ? 64 : 54,
                        height: isTablet ? 64 : 54,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF0EBE1),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initial,
                          style: GoogleFonts.montserrat(
                            fontSize: isTablet ? 26 : 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF6B5800),
                          ),
                        ),
                      ),
                      SizedBox(width: isTablet ? 20 : 16),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              party.name,
                              style: GoogleFonts.montserrat(
                                fontSize: isTablet ? 20 : 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone_outlined,
                                  size: isTablet ? 16 : 13,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  party.phone.isNotEmpty ? party.phone : 'No Phone Number',
                                  style: GoogleFonts.montserrat(
                                    fontSize: isTablet ? 15 : 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 16 : 12,
                                  vertical: isTablet ? 8 : 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5EFE6),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                ),
                                child: Text(
                                  txnCount == 1 ? '1 Transaction' : '$txnCount Transactions',
                                  style: GoogleFonts.montserrat(
                                    fontSize: isTablet ? 16 : 13,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF6B5800),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.grey[400],
                                size: isTablet ? 24 : 20,
                              ),
                            ],
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
  }

  PartyDetail _getPartyDetail(PartyModel party) {
    final name = party.name;
    final type = party.type;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    String location = party.address.isNotEmpty 
        ? party.address.split(',').last.trim() 
        : 'India';

    List<PartyTransaction> transactions = [];

    String totalCashDue = '₹${NumberFormat.decimalPattern('en_IN').format(party.cashBalance.abs())}';
    String cashDueLabel = party.cashBalance >= 0 ? 'They Owe' : 'You Owe';
    bool isCashYouOwe = party.cashBalance < 0;

    String totalGoldDue = '${party.goldBalanceGrams.abs().toStringAsFixed(3)} g';
    String goldDueLabel = party.goldBalanceGrams >= 0 ? 'They Owe' : 'You Owe';
    bool isGoldYouOwe = party.goldBalanceGrams < 0;

    return PartyDetail(
      id: party.id,
      name: name,
      type: type,
      location: location,
      initial: initial,
      totalCashDue: totalCashDue,
      cashDueLabel: cashDueLabel,
      isCashYouOwe: isCashYouOwe,
      totalGoldDue: totalGoldDue,
      goldDueLabel: goldDueLabel,
      isGoldYouOwe: isGoldYouOwe,
      phone: party.phone,
      transactions: transactions,
    );
  }
}
