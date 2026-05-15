import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'Today';

  final List<Map<String, dynamic>> _upcomingCalls = [
    {
      'status': 'OVERDUE',
      'statusColor': const Color(0xFFC62828),
      'borderColor': const Color(0xFFC62828),
      'date': 'Today, 10:00 AM',
      'name': 'Rajesh Verma',
      'phone': '+91 98765 43210',
      'note': 'Customer promised to clear the pending balance of ₹45,000 for the gold chain purchased last...',
      'subtitle': 'Payment Follow-up',
    },
    {
      'status': 'UPCOMING',
      'statusColor': const Color(0xFF6B5800),
      'borderColor': const Color(0xFF6B5800),
      'date': 'Today, 2:30 PM',
      'name': 'Meera Sharma',
      'phone': '+91 87654 32109',
      'note': 'Inform customer that the custom diamond ring design is finalized and ready for pickup. Verify...',
      'subtitle': 'Custom Order Ready',
    },
    {
      'status': 'TOMORROW',
      'statusColor': const Color(0xFF2852C6),
      'borderColor': const Color(0xFF2852C6),
      'date': 'Tomorrow, 11:00 AM',
      'name': 'Anil Gupta',
      'phone': '+91 76543 21098',
      'note': 'Follow up on the silver coin sets inquiry for corporate Diwali gifting. Offer the bulk discount',
      'subtitle': 'Gifting Inquiry',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFDFBF7),
      child: SafeArea(
        child: Column(
          children: [
            _buildTabBar(),
            const SizedBox(height: 16),
            _buildHeader(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildUpcomingList(),
                  const Center(child: Text('History Data')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0D8CA), width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF6B5800),
        unselectedLabelColor: Colors.grey[600],
        labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 14),
        unselectedLabelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w500, fontSize: 14),
        indicatorColor: const Color(0xFF6B5800),
        indicatorWeight: 2,
        tabs: const [
          Tab(text: 'Upcoming'),
          Tab(text: 'History'),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Upcoming Calls',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE0D8CA)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedFilter,
                icon: const Icon(Icons.filter_list, size: 16, color: Color(0xFF6B5800)),
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B5800),
                ),
                isDense: true,
                items: ['Today', 'This Week', 'All'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedFilter = newValue;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _upcomingCalls.length + 1,
      itemBuilder: (context, index) {
        if (index == _upcomingCalls.length) {
          return _buildFooter();
        }
        final call = _upcomingCalls[index];
        return _buildCallCard(call);
      },
    );
  }

  Widget _buildCallCard(Map<String, dynamic> call) {
    IconData statusIcon = Icons.error_outline;
    if (call['status'] == 'UPCOMING') statusIcon = Icons.access_time;
    if (call['status'] == 'TOMORROW') statusIcon = Icons.calendar_today_outlined;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
              width: 4,
              decoration: BoxDecoration(
                color: call['borderColor'],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(statusIcon, size: 14, color: call['statusColor']),
                            const SizedBox(width: 4),
                            Text(
                              call['status'],
                              style: GoogleFonts.montserrat(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: call['statusColor'],
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          call['date'],
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: call['statusColor'],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          call['name'],
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          call['subtitle'],
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone_android, size: 14, color: Colors.black54),
                        const SizedBox(width: 4),
                        Text(
                          call['phone'],
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F7F2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        call['note'],
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: Colors.grey[800],
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFE0D8CA)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              'Reschedule',
                              style: GoogleFonts.montserrat(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF37),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.call, size: 16, color: Colors.black87),
                                const SizedBox(width: 8),
                                Text(
                                  'Call Now',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        children: [
          Icon(Icons.calendar_today_outlined, size: 40, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'No more upcoming reminders for this week.',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 80), // Padding for bottom nav
        ],
      ),
    );
  }
}
