import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ──────────────────────────── DATA MODELS ────────────────────────────

class PartyTransaction {
  final String title;
  final String subtitle; // e.g. "24 Oct 2023 • 10:30 AM"
  final String? notes; // Optional notes below date/time
  final String amount; // e.g. "- 50.000 g" or "+ ₹ 1,00,000"
  final String amountSubtitle; // e.g. "Gold (22K)" or "NEFT / RTGS"
  final Color amountColor;
  final String category; // "cash", "online", "metal"
  final IconData? icon;

  const PartyTransaction({
    required this.title,
    required this.subtitle,
    this.notes,
    required this.amount,
    required this.amountSubtitle,
    required this.amountColor,
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
  final List<String> _filters = ['All', 'Money', 'Diamond', 'Gold'];
  String _selectedTab = 'Transactions';
  String _selectedReminderTime = 'Tomorrow';
  final TextEditingController _reminderMsgController = TextEditingController();
  
  DateTime? _customDate;
  TimeOfDay? _customTime;
  bool _isSavingReminder = false;

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  void initState() {
    super.initState();
    // Start with empty text so the placeholder "Type your message..." shows.
  }

  @override
  void dispose() {
    _reminderMsgController.dispose();
    super.dispose();
  }

  List<PartyTransaction> get _filteredTransactions {
    if (_selectedFilter == 'All') return widget.party.transactions;
    return widget.party.transactions.where((t) {
      final category = t.category.toLowerCase();
      final filter = _selectedFilter.toLowerCase();
      
      if (filter == 'money') {
        return category == 'cash' || category == 'online' || category == 'money';
      }
      if (filter == 'gold') {
        return category == 'metal' || category == 'gold';
      }
      return category == filter;
    }).toList();
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
                    _buildTabs(),
                    const SizedBox(height: 20),
                    if (_selectedTab == 'Transactions') ...[
                      _buildFilterTabs(),
                      const SizedBox(height: 16),
                      _buildTransactionList(),
                      const SizedBox(height: 24),
                      _buildOlderTransactionsLink(),
                    ] else ...[
                      _buildReminderTabContent(),
                    ],
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

  // ─── TABS ─────────────────────────────────────────
  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Transactions',
              isSelected: _selectedTab == 'Transactions',
              onTap: () => setState(() => _selectedTab = 'Transactions'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTabButton(
              icon: Icons.notifications_none,
              label: 'Reminders',
              isSelected: _selectedTab == 'Reminders',
              onTap: () => setState(() => _selectedTab = 'Reminders'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final backgroundColor = isSelected ? const Color(0xFF4A3E1F) : const Color(0xFFF5EFE6);
    final textColor = isSelected ? Colors.white : const Color(0xFF4A3E1F);
    
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── REMINDER TAB CONTENT ─────────────────────────────────────
  Widget _buildReminderTabContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add Reminder Form
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0D8CA)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9F7F2),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.notifications_active_outlined,
                            size: 20, color: Color(0xFFD4AF37)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'New Reminder',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E1E1E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Message Input
                      TextField(
                        controller: _reminderMsgController,
                        maxLines: null,
                        minLines: 3,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: Colors.grey[800],
                          height: 1.5,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          filled: true,
                          fillColor: const Color(0xFFF9F7F2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE0D8CA)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE0D8CA)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF4A3E1F)),
                          ),
                          contentPadding: const EdgeInsets.all(14),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'When',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          'Tomorrow',
                          'In 2 days',
                          'Next Week',
                          'Custom Date',
                        ].map((time) {
                          final isSelected = _selectedReminderTime == time;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedReminderTime = time),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFFF5EFE6),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFFE0D8CA),
                                ),
                              ),
                              child: Text(
                                time,
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected ? const Color(0xFF4A3E1F) : Colors.grey[700],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      if (_selectedReminderTime == 'Custom Date') ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Date',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  InkWell(
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: _customDate ?? DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2100),
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: const ColorScheme.light(
                                                primary: Color(0xFF4A3E1F),
                                                onPrimary: Colors.white,
                                                onSurface: Colors.black,
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (picked != null) {
                                        setState(() => _customDate = picked);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: const Color(0xFFD4AF37)),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF6B5800)),
                                          const SizedBox(width: 8),
                                          Text(
                                            _customDate != null ? _formatDate(_customDate!) : 'Select Date',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: _customDate != null ? Colors.black87 : Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Time',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  InkWell(
                                    onTap: () async {
                                      final picked = await showTimePicker(
                                        context: context,
                                        initialTime: _customTime ?? TimeOfDay.now(),
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: const ColorScheme.light(
                                                primary: Color(0xFF4A3E1F),
                                                onPrimary: Colors.white,
                                                onSurface: Colors.black,
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (picked != null) {
                                        setState(() => _customTime = picked);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: const Color(0xFFE0D8CA)),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.access_time, size: 18, color: Color(0xFF6B5800)),
                                          const SizedBox(width: 8),
                                          Text(
                                            _customTime != null ? _customTime!.format(context) : 'Select Time',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: _customTime != null ? Colors.black87 : Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),
                      // Save button
                      Material(
                        color: const Color(0xFF4A3E1F),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _isSavingReminder
                              ? null
                              : () async {
                                  setState(() => _isSavingReminder = true);
                                  // Simulate network save
                                  await Future.delayed(const Duration(milliseconds: 800));
                                  if (mounted) {
                                    setState(() {
                                      _isSavingReminder = false;
                                      _reminderMsgController.clear();
                                      _customDate = null;
                                      _customTime = null;
                                      _selectedReminderTime = 'Tomorrow';
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Saved to Reminders',
                                          style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        backgroundColor: const Color(0xFF4A3E1F),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    );
                                  }
                                },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isSavingReminder)
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                else
                                  const Icon(Icons.bookmark_added_outlined, size: 18, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  _isSavingReminder ? 'Saving...' : 'Save to Reminders',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
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
            ),
          ),
          const SizedBox(height: 32),
          // Previous Reminders Section
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: const Color(0xFFE0D8CA),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'PREVIOUS REMINDERS',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[600],
                    letterSpacing: 1,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: const Color(0xFFE0D8CA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Mock reminder items
          _buildPreviousReminderCard(
            status: 'Pending',
            date: 'Tomorrow, 10:00 AM',
            title: 'Call after 2 days',
            note: 'Discuss the pending payment for invoice #INV-2023-089. They promised to clear half the amount.',
            isPending: true,
          ),
          _buildPreviousReminderCard(
            status: 'Pending',
            date: 'Oct 25, 2023',
            title: 'Share new Diwali collection',
            note: 'Send PDF catalog of the new antique gold temple jewellery collection.',
            isPending: true,
          ),
          _buildPreviousReminderCard(
            status: 'Completed',
            date: 'Oct 10, 2023',
            title: 'Collect silver scrap',
            note: 'Picked up 2kg silver scrap for melting.',
            isPending: false,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviousReminderCard({
    required String status,
    required String date,
    required String title,
    required String note,
    required bool isPending,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0D8CA)),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPending ? const Color(0xFFF5EFE6) : const Color(0xFFF9F7F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isPending ? const Color(0xFFE0D8CA) : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (isPending)
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF6B5800),
                              shape: BoxShape.circle,
                            ),
                          )
                        else
                          const Icon(Icons.check, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          status,
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isPending ? const Color(0xFF6B5800) : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    date,
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              Icon(Icons.more_vert, size: 18, color: Colors.grey[600]),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            note,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          if (isPending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check, size: 14),
                  label: const Text('Mark Done'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4A3E1F),
                    side: const BorderSide(color: Color(0xFFE0D8CA)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: const BorderSide(color: Color(0xFFE0D8CA)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ],
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
    // Determine left border color based on category
    Color leftBorderColor;
    final cat = txn.category.toLowerCase();
    if (cat == 'metal' || cat == 'gold') {
      leftBorderColor = const Color(0xFFC7A22A);
    } else if (cat == 'diamond') {
      leftBorderColor = const Color(0xFF7E57C2);
    } else if (cat == 'cash' || cat == 'online' || cat == 'money') {
      leftBorderColor = const Color(0xFF2852C6);
    } else {
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
                    if (txn.notes != null && txn.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F7F2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          txn.notes!,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
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
