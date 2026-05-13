import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ──────────────────────────── DATA MODELS ────────────────────────────

class PartyTransaction {
  final String title;
  final String subtitle; // e.g. "24 Oct 2023 • 10:30 AM"
  final String tag; // e.g. "Sales", "Receipt", "Return"
  final String amount; // e.g. "- 50.000 g" or "+ ₹ 1,00,000"
  final String amountSubtitle; // e.g. "Gold (22K)" or "NEFT / RTGS"
  final Color amountColor;
  final Color tagColor;
  final Color tagTextColor;
  final String category; // "cash", "online", "metal"
  final IconData? icon;

  const PartyTransaction({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.amount,
    required this.amountSubtitle,
    required this.amountColor,
    required this.tagColor,
    required this.tagTextColor,
    required this.category,
    this.icon,
  });
}

class PartyDetail {
  final String name;
  final String type; // e.g. "Wholesale Partner"
  final String location; // e.g. "Mumbai"
  final String initial;
  final String totalCashDue;
  final String cashDueLabel; // e.g. "You Owe" or "They Owe"
  final bool isCashYouOwe; // true = You Owe (red arrow up), false = They Owe (blue arrow down)
  final String totalGoldDue;
  final String goldDueLabel;
  final bool isGoldYouOwe;
  final List<PartyTransaction> transactions;

  const PartyDetail({
    required this.name,
    required this.type,
    required this.location,
    required this.initial,
    required this.totalCashDue,
    required this.cashDueLabel,
    required this.isCashYouOwe,
    required this.totalGoldDue,
    required this.goldDueLabel,
    required this.isGoldYouOwe,
    required this.transactions,
  });
}

// ──────────────────────────── SCREEN ────────────────────────────

class PartyDetailScreen extends StatefulWidget {
  final PartyDetail party;

  const PartyDetailScreen({super.key, required this.party});

  @override
  State<PartyDetailScreen> createState() => _PartyDetailScreenState();
}

class _PartyDetailScreenState extends State<PartyDetailScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Cash', 'Online', 'Metal'];

  List<PartyTransaction> get _filteredTransactions {
    if (_selectedFilter == 'All') return widget.party.transactions;
    return widget.party.transactions
        .where((t) => t.category.toLowerCase() == _selectedFilter.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildDueSummaryCards(),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                    const SizedBox(height: 20),
                    _buildFilterTabs(),
                    const SizedBox(height: 16),
                    _buildTransactionList(),
                    const SizedBox(height: 24),
                    _buildOlderTransactionsLink(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── APP BAR ─────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1E1E), size: 24),
            splashRadius: 24,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.party.name,
                  style: GoogleFonts.montserrat(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E1E1E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.party.type} • ${widget.party.location}',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              _showMoreOptions(context);
            },
            icon: const Icon(Icons.more_vert, color: Color(0xFF1E1E1E), size: 24),
            splashRadius: 24,
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                _buildOptionTile(Icons.edit_outlined, 'Edit Party Details'),
                _buildOptionTile(Icons.file_download_outlined, 'Download Statement'),
                _buildOptionTile(Icons.share_outlined, 'Share Ledger'),
                _buildOptionTile(Icons.delete_outline, 'Delete Party', isDestructive: true),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionTile(IconData icon, String title, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red[700] : const Color(0xFF4A3E1F),
      ),
      title: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red[700] : const Color(0xFF1E1E1E),
        ),
      ),
      onTap: () => Navigator.pop(context),
    );
  }

  // ─── DUE SUMMARY CARDS ──────────────────────────────────────
  Widget _buildDueSummaryCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildDueCard(
              label: 'Total Cash Due',
              value: widget.party.totalCashDue,
              statusLabel: widget.party.cashDueLabel,
              isYouOwe: widget.party.isCashYouOwe,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDueCard(
              label: 'Total Gold Due',
              value: widget.party.totalGoldDue,
              statusLabel: widget.party.goldDueLabel,
              isYouOwe: widget.party.isGoldYouOwe,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDueCard({
    required String label,
    required String value,
    required String statusLabel,
    required bool isYouOwe,
  }) {
    final statusColor = isYouOwe ? const Color(0xFFC62828) : const Color(0xFF2852C6);
    final arrowIcon = isYouOwe ? Icons.north_east : Icons.south_west;
    final bgDecorColor = isYouOwe
        ? const Color(0xFFC62828).withOpacity(0.06)
        : const Color(0xFF2852C6).withOpacity(0.06);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative circle
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bgDecorColor,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(arrowIcon, size: 14, color: statusColor),
                  const SizedBox(width: 4),
                  Text(
                    statusLabel,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── ACTION BUTTONS ─────────────────────────────────────────
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildActionButton(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Settle',
              backgroundColor: const Color(0xFF4A3E1F),
              textColor: Colors.white,
              iconColor: Colors.white,
            ),
            const SizedBox(width: 12),
            _buildActionButton(
              icon: Icons.message_outlined,
              label: 'Remind',
              backgroundColor: const Color(0xFFF5EFE6),
              textColor: const Color(0xFF4A3E1F),
              iconColor: const Color(0xFF4A3E1F),
            ),
            const SizedBox(width: 12),
            _buildActionButton(
              icon: Icons.file_copy_outlined,
              label: 'Export',
              backgroundColor: const Color(0xFFF5EFE6),
              textColor: const Color(0xFF4A3E1F),
              iconColor: const Color(0xFF4A3E1F),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required Color iconColor,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () {
          // Action placeholder
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── FILTER TABS ────────────────────────────────────────────
  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0D8CA), width: 1),
        ),
      ),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 24),
              padding: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? const Color(0xFF4A3E1F) : Colors.transparent,
                    width: 2.5,
                  ),
                ),
              ),
              child: Text(
                filter,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF4A3E1F) : Colors.grey[500],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── TRANSACTION LIST ───────────────────────────────────────
  Widget _buildTransactionList() {
    final transactions = _filteredTransactions;

    if (transactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                'No transactions found',
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: transactions.map((txn) => _buildTransactionCard(txn)).toList(),
      ),
    );
  }

  Widget _buildTransactionCard(PartyTransaction txn) {
    // Determine left border color based on tag
    Color leftBorderColor;
    switch (txn.tag.toLowerCase()) {
      case 'sales':
        leftBorderColor = const Color(0xFFC7A22A);
        break;
      case 'receipt':
        leftBorderColor = const Color(0xFF2852C6);
        break;
      case 'return':
        leftBorderColor = const Color(0xFF6B5800);
        break;
      case 'purchase':
        leftBorderColor = const Color(0xFFC62828);
        break;
      default:
        leftBorderColor = const Color(0xFF4A3E1F);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left colored accent bar
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: leftBorderColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row with amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    txn.title,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1E1E1E),
                                    ),
                                  ),
                                  if (txn.icon != null) ...[
                                    const SizedBox(width: 6),
                                    Icon(txn.icon, size: 18, color: Colors.grey[600]),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                txn.subtitle,
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              txn.amount,
                              style: GoogleFonts.montserrat(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: txn.amountColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              txn.amountSubtitle,
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Tag chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: txn.tagColor,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: txn.tagTextColor.withOpacity(0.15),
                        ),
                      ),
                      child: Text(
                        txn.tag,
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: txn.tagTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── OLDER TRANSACTIONS LINK ────────────────────────────────
  Widget _buildOlderTransactionsLink() {
    return Center(
      child: TextButton(
        onPressed: () {
          // Load older transactions
        },
        child: Text(
          'Older Transactions',
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6B5800),
            decoration: TextDecoration.underline,
            decorationColor: const Color(0xFF6B5800),
          ),
        ),
      ),
    );
  }
}
