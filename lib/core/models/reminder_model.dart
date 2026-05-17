import 'package:cloud_firestore/cloud_firestore.dart';

enum ReminderStatus { upcoming, overdue, completed }

class ReminderModel {
  final String id;
  final String userId;
  final String partyId;
  final String partyName;
  final String partyPhone;
  final String title;
  final String note;
  final DateTime date;
  final ReminderStatus status;
  final DateTime createdAt;

  const ReminderModel({
    required this.id,
    required this.userId,
    required this.partyId,
    required this.partyName,
    required this.partyPhone,
    required this.title,
    required this.note,
    required this.date,
    required this.status,
    required this.createdAt,
  });

  factory ReminderModel.fromMap(String id, Map<String, dynamic> map) {
    return ReminderModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      partyId: map['partyId'] as String? ?? '',
      partyName: map['partyName'] as String? ?? '',
      partyPhone: map['partyPhone'] as String? ?? '',
      title: map['title'] as String? ?? '',
      note: map['note'] as String? ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: ReminderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ReminderStatus.upcoming,
      ),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'partyId': partyId,
      'partyName': partyName,
      'partyPhone': partyPhone,
      'title': title,
      'note': note,
      'date': Timestamp.fromDate(date),
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ReminderModel copyWith({
    String? title,
    String? note,
    DateTime? date,
    ReminderStatus? status,
  }) {
    return ReminderModel(
      id: id,
      userId: userId,
      partyId: partyId,
      partyName: partyName,
      partyPhone: partyPhone,
      title: title ?? this.title,
      note: note ?? this.note,
      date: date ?? this.date,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
