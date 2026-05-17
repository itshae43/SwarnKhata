import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:swarn_khata/features/reminders/providers/reminder_providers.dart';
import 'package:swarn_khata/core/models/reminder_model.dart';
import 'package:swarn_khata/core/utils/communication_utils.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'Today';

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
                  _buildHistoryList(),
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
    final remindersAsync = ref.watch(remindersStreamProvider);

    return remindersAsync.when(
      data: (reminders) {
        final upcoming = reminders.where((r) => r.status != ReminderStatus.completed).toList();
        
        // Sorting by date (sooner first)
        upcoming.sort((a, b) => a.date.compareTo(b.date));

        if (upcoming.isEmpty) {
          return _buildEmptyState('No upcoming reminders');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: upcoming.length + 1,
          itemBuilder: (context, index) {
            if (index == upcoming.length) {
              return _buildFooter();
            }
            final reminder = upcoming[index];
            return _buildCallCard(reminder);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildHistoryList() {
    final remindersAsync = ref.watch(remindersStreamProvider);

    return remindersAsync.when(
      data: (reminders) {
        final history = reminders.where((r) => r.status == ReminderStatus.completed).toList();
        
        // Sorting by date (newest first)
        history.sort((a, b) => b.date.compareTo(a.date));

        if (history.isEmpty) {
          return _buildEmptyState('No history yet');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final reminder = history[index];
            return _buildCallCard(reminder);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(msg, style: GoogleFonts.montserrat(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCallCard(ReminderModel reminder) {
    final isPending = reminder.status != ReminderStatus.completed;
    
    // Logic for status label and color
    String statusLabel = '';
    Color statusColor = const Color(0xFF6B5800); // Default UPCOMING
    IconData statusIcon = Icons.access_time;

    final now = DateTime.now();
    final isOverdue = reminder.date.isBefore(now) && isPending;
    final isTomorrow = reminder.date.day == now.add(const Duration(days: 1)).day && 
                      reminder.date.month == now.month && 
                      reminder.date.year == now.year;
    final isToday = reminder.date.day == now.day && 
                    reminder.date.month == now.month && 
                    reminder.date.year == now.year;

    if (!isPending) {
      statusLabel = 'COMPLETED';
      statusColor = Colors.grey;
      statusIcon = Icons.check_circle_outline;
    } else if (isOverdue) {
      statusLabel = 'OVERDUE';
      statusColor = const Color(0xFFC62828);
      statusIcon = Icons.error_outline;
    } else if (isToday) {
      statusLabel = 'TODAY';
      statusColor = const Color(0xFF6B5800);
      statusIcon = Icons.access_time;
    } else if (isTomorrow) {
      statusLabel = 'TOMORROW';
      statusColor = const Color(0xFF2852C6);
      statusIcon = Icons.calendar_today_outlined;
    } else {
      statusLabel = 'UPCOMING';
      statusColor = const Color(0xFF6B5800);
      statusIcon = Icons.access_time;
    }

    final dateStr = DateFormat('dd MMM, hh:mm a').format(reminder.date);

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
                color: statusColor,
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
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(statusIcon, size: 14, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              statusLabel,
                              style: GoogleFonts.montserrat(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          dateStr,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
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
                          reminder.partyName,
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          reminder.title,
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.phone_android, size: 14, color: Colors.black87),
                              const SizedBox(width: 6),
                              Text(
                                reminder.partyPhone.isNotEmpty ? reminder.partyPhone : 'No phone number saved',
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
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
                        reminder.note,
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: Colors.grey[800],
                          height: 1.4,
                        ),
                      ),
                    ),
                    if (isPending) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildActionIcon(
                            icon: Icons.call,
                            color: const Color(0xFF2E7D32),
                            onTap: () => CommunicationUtils.makeCall(reminder.partyPhone),
                            label: 'Call',
                          ),
                          const SizedBox(width: 12),
                          _buildActionIcon(
                            icon: Icons.message_outlined,
                            color: const Color(0xFF0288D1),
                            onTap: () => CommunicationUtils.sendSMS(reminder.partyPhone),
                            label: 'SMS',
                          ),
                          const SizedBox(width: 12),
                          _buildActionIcon(
                            icon: Icons.chat_outlined,
                            color: const Color(0xFF25D366),
                            onTap: () => CommunicationUtils.launchWhatsApp(reminder.partyPhone, reminder.note),
                            label: 'WA',
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => _showEditReminderDialog(reminder),
                            child: Text(
                              'Edit',
                              style: GoogleFonts.montserrat(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              ref.read(reminderNotifierProvider.notifier).markAsDone(reminder.id);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF37),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            child: const Icon(Icons.check, size: 18, color: Colors.black87),
                          ),
                        ],
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

  Widget _buildActionIcon({required IconData icon, required Color color, required VoidCallback onTap, required String label}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showEditReminderDialog(ReminderModel reminder) {
    final noteController = TextEditingController(text: reminder.note);
    DateTime selectedDate = reminder.date;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Reminder', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Note'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text('Date: ${DateFormat('dd MMM yyyy • hh:mm a').format(selectedDate)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(selectedDate),
                  );
                  if (time != null) {
                    selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                  }
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(reminderNotifierProvider.notifier).updateReminder(
                reminder.copyWith(note: noteController.text, date: selectedDate),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A3E1F)),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
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
