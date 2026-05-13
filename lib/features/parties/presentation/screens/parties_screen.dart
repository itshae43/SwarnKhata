import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'party_detail_screen.dart';

class PartiesScreen extends StatefulWidget {
  const PartiesScreen({super.key});

  @override
  State<PartiesScreen> createState() => _PartiesScreenState();
}

class _PartiesScreenState extends State<PartiesScreen> {
  String _selectedFilter = 'All Parties';
  final List<String> _filters = ['All Parties', 'Receivables (Dr)', 'Payables','Net Position'];
  final List<Map<String, dynamic>> _parties = [
    {
      'name': 'Rahul Sharma',
      'type': 'Retail Customer',
      'initial': 'R',
      'hasIcon': false,
      'amount': '₹12,000',
      'amountColor': const Color(0xFF1E1E1E),
      'status': 'Dr (To Receive)',
      'statusColor': const Color(0xFF2852C6),
      'leftBorderColor': const Color(0xFF2852C6),
      'avatarColor': const Color(0xFFEBE3D5),
      'iconColor': const Color(0xFF4A3E1F),
    },
    {
      'name': 'Sri Ganesh...',
      'type': 'B2B Supplier',
      'initial': '',
      'hasIcon': true,
      'icon': Icons.workspace_premium_outlined,
      'amount': '200g 24K',
      'amountColor': const Color(0xFFC7A22A),
      'status': 'Cr (To Give)',
      'statusColor': const Color(0xFF6B5800),
      'leftBorderColor': const Color(0xFFC7A22A),
      'avatarColor': const Color(0xFFFFEEB3),
      'iconColor': const Color(0xFF4A3E1F),
    },
    {
      'name': 'Anita Ben',
      'type': 'Karigar (Artisan)',
      'initial': 'A',
      'hasIcon': false,
      'amount': '₹45,000',
      'amountColor': const Color(0xFF1E1E1E),
      'status': 'Cr (To Pay)',
      'statusColor': const Color(0xFFC62828),
      'leftBorderColor': const Color(0xFFC62828),
      'avatarColor': const Color(0xFFEBE3D5),
      'iconColor': const Color(0xFF4A3E1F),
    },
    {
      'name': 'Sri Ganesh...',
      'type': 'B2B Supplier',
      'initial': '',
      'hasIcon': true,
      'icon': Icons.workspace_premium_outlined,
      'amount': '200g 24K',
      'amountColor': const Color(0xFFC7A22A),
      'status': 'Cr (To Give)',
      'statusColor': const Color(0xFF6B5800),
      'leftBorderColor': const Color(0xFFC7A22A),
      'avatarColor': const Color(0xFFFFEEB3),
      'iconColor': const Color(0xFF4A3E1F),
    },
  ];

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
              const SizedBox(height: 20),
              _buildFilterChips(),
              const SizedBox(height: 24),
              _buildPartiesList(),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search parties by name or ID...',
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFD4B13B) : const Color(0xFFEBE3D5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  filter,
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFF4A3E1F),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPartiesList() {
    return Column(
      children: _parties.map((party) {
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
            margin: const EdgeInsets.only(bottom: 12),
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
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 5,
                    decoration: BoxDecoration(
                      color: party['leftBorderColor'] as Color,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: party['avatarColor'] as Color,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: (party['hasIcon'] as bool)
                                ? Icon(
                                    party['icon'] as IconData,
                                    color: party['iconColor'] as Color,
                                    size: 24,
                                  )
                                : Text(
                                    party['initial'] as String,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: party['iconColor'] as Color,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  party['name'] as String,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  party['type'] as String,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
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
                                party['amount'] as String,
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: party['amountColor'] as Color,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                party['status'] as String,
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: party['statusColor'] as Color,
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
  }

  // ─── MAP PARTY DATA TO PARTY DETAIL MODEL ─────────────────────
  PartyDetail _getPartyDetail(Map<String, dynamic> party) {
    final name = party['name'] as String;
    final type = party['type'] as String;
    final initial = (party['hasIcon'] as bool)
        ? (name.isNotEmpty ? name[0] : '?')
        : party['initial'] as String;

    // Determine location based on party type
    String location;
    switch (type) {
      case 'Retail Customer':
        location = 'Ahmedabad';
        break;
      case 'B2B Supplier':
        location = 'Mumbai';
        break;
      case 'Karigar (Artisan)':
        location = 'Rajkot';
        break;
      default:
        location = 'India';
    }

    // Generate personalized transactions based on the party
    List<PartyTransaction> transactions;

    if (type == 'Retail Customer') {
      transactions = [
        PartyTransaction(
          title: 'Invoice #101',
          subtitle: '10 Nov 2023 • 11:00 AM',
          tag: 'Sales',
          amount: '- 25.000 g',
          amountSubtitle: 'Gold (22K)',
          amountColor: const Color(0xFFC62828),
          tagColor: const Color(0xFFFFF8E1),
          tagTextColor: const Color(0xFF6B5800),
          category: 'metal',
        ),
        PartyTransaction(
          title: 'Payment',
          subtitle: '08 Nov 2023 • 03:45 PM',
          tag: 'Receipt',
          amount: '+ ₹ 50,000',
          amountSubtitle: 'UPI / GPay',
          amountColor: const Color(0xFF2E7D32),
          tagColor: const Color(0xFFE8F5E9),
          tagTextColor: const Color(0xFF2E7D32),
          category: 'online',
          icon: Icons.check_circle_outline,
        ),
        PartyTransaction(
          title: 'Payment',
          subtitle: '05 Nov 2023 • 10:15 AM',
          tag: 'Receipt',
          amount: '+ ₹ 30,000',
          amountSubtitle: 'Cash',
          amountColor: const Color(0xFF2E7D32),
          tagColor: const Color(0xFFE8F5E9),
          tagTextColor: const Color(0xFF2E7D32),
          category: 'cash',
          icon: Icons.check_circle_outline,
        ),
      ];
    } else if (type == 'B2B Supplier') {
      transactions = [
        PartyTransaction(
          title: 'Invoice #123',
          subtitle: '24 Oct 2023 • 10:30 AM',
          tag: 'Sales',
          amount: '- 50.000 g',
          amountSubtitle: 'Gold (22K)',
          amountColor: const Color(0xFFC62828),
          tagColor: const Color(0xFFFFF8E1),
          tagTextColor: const Color(0xFF6B5800),
          category: 'metal',
        ),
        PartyTransaction(
          title: 'Payment',
          subtitle: '22 Oct 2023 • 02:15 PM',
          tag: 'Receipt',
          amount: '+ ₹ 1,00,000',
          amountSubtitle: 'NEFT / RTGS',
          amountColor: const Color(0xFF2E7D32),
          tagColor: const Color(0xFFE8F5E9),
          tagTextColor: const Color(0xFF2E7D32),
          category: 'online',
          icon: Icons.check_circle_outline,
        ),
        PartyTransaction(
          title: 'Metal Return',
          subtitle: '20 Oct 2023 • 11:00 AM',
          tag: 'Return',
          amount: '+ 10.000 g',
          amountSubtitle: 'Gold (22K)',
          amountColor: const Color(0xFF2E7D32),
          tagColor: const Color(0xFFFFF3E0),
          tagTextColor: const Color(0xFF6B5800),
          category: 'metal',
        ),
        PartyTransaction(
          title: 'Purchase',
          subtitle: '18 Oct 2023 • 09:00 AM',
          tag: 'Purchase',
          amount: '- ₹ 2,50,000',
          amountSubtitle: 'NEFT / RTGS',
          amountColor: const Color(0xFFC62828),
          tagColor: const Color(0xFFFFEBEE),
          tagTextColor: const Color(0xFFC62828),
          category: 'online',
        ),
      ];
    } else if (type == 'Karigar (Artisan)') {
      transactions = [
        PartyTransaction(
          title: 'Labour Payment',
          subtitle: '15 Nov 2023 • 06:00 PM',
          tag: 'Receipt',
          amount: '- ₹ 25,000',
          amountSubtitle: 'Cash',
          amountColor: const Color(0xFFC62828),
          tagColor: const Color(0xFFE8F5E9),
          tagTextColor: const Color(0xFF2E7D32),
          category: 'cash',
        ),
        PartyTransaction(
          title: 'Gold Given for Work',
          subtitle: '12 Nov 2023 • 10:00 AM',
          tag: 'Sales',
          amount: '- 15.000 g',
          amountSubtitle: 'Gold (24K)',
          amountColor: const Color(0xFFC62828),
          tagColor: const Color(0xFFFFF8E1),
          tagTextColor: const Color(0xFF6B5800),
          category: 'metal',
        ),
        PartyTransaction(
          title: 'Finished Goods Received',
          subtitle: '10 Nov 2023 • 04:30 PM',
          tag: 'Return',
          amount: '+ 14.500 g',
          amountSubtitle: 'Gold (22K)',
          amountColor: const Color(0xFF2E7D32),
          tagColor: const Color(0xFFFFF3E0),
          tagTextColor: const Color(0xFF6B5800),
          category: 'metal',
        ),
        PartyTransaction(
          title: 'Labour Payment',
          subtitle: '01 Nov 2023 • 12:00 PM',
          tag: 'Receipt',
          amount: '- ₹ 20,000',
          amountSubtitle: 'UPI / GPay',
          amountColor: const Color(0xFFC62828),
          tagColor: const Color(0xFFE8F5E9),
          tagTextColor: const Color(0xFF2E7D32),
          category: 'online',
        ),
      ];
    } else {
      transactions = [
        PartyTransaction(
          title: 'Transaction',
          subtitle: '01 Nov 2023 • 12:00 PM',
          tag: 'Sales',
          amount: '₹ 10,000',
          amountSubtitle: 'Cash',
          amountColor: const Color(0xFF1E1E1E),
          tagColor: const Color(0xFFFFF8E1),
          tagTextColor: const Color(0xFF6B5800),
          category: 'cash',
        ),
      ];
    }

    // Determine due amounts based on party data
    String totalCashDue;
    String cashDueLabel;
    bool isCashYouOwe;
    String totalGoldDue;
    String goldDueLabel;
    bool isGoldYouOwe;

    final status = party['status'] as String;
    if (status.contains('To Receive')) {
      totalCashDue = party['amount'] as String;
      cashDueLabel = 'They Owe';
      isCashYouOwe = false;
      totalGoldDue = '0.000 g';
      goldDueLabel = 'Settled';
      isGoldYouOwe = false;
    } else if (status.contains('To Give')) {
      totalCashDue = '₹ 1,50,000';
      cashDueLabel = 'You Owe';
      isCashYouOwe = true;
      totalGoldDue = (party['amount'] as String).replaceAll('24K', '').trim();
      goldDueLabel = 'They Owe';
      isGoldYouOwe = false;
    } else {
      totalCashDue = party['amount'] as String;
      cashDueLabel = 'You Owe';
      isCashYouOwe = true;
      totalGoldDue = '15.000 g';
      goldDueLabel = 'You Owe';
      isGoldYouOwe = true;
    }

    return PartyDetail(
      name: name == 'Sri Ganesh...' ? 'Sri Ganesh Wholesalers' : name,
      type: type == 'B2B Supplier' ? 'Wholesale Partner' : type,
      location: location,
      initial: initial,
      totalCashDue: totalCashDue,
      cashDueLabel: cashDueLabel,
      isCashYouOwe: isCashYouOwe,
      totalGoldDue: totalGoldDue,
      goldDueLabel: goldDueLabel,
      isGoldYouOwe: isGoldYouOwe,
      transactions: transactions,
    );
  }
}
