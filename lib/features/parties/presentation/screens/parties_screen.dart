import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        return Container(
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
        );
      }).toList(),
    );
  }
}
