import 'package:cloud_firestore/cloud_firestore.dart';

class SessionModel {
  final String id;
  final String deviceName;
  final String os;
  final DateTime createdAt;
  final DateTime lastActiveAt;

  const SessionModel({
    required this.id,
    required this.deviceName,
    required this.os,
    required this.createdAt,
    required this.lastActiveAt,
  });

  factory SessionModel.fromMap(String id, Map<String, dynamic> map) {
    return SessionModel(
      id: id,
      deviceName: map['deviceName'] as String? ?? 'Unknown Device',
      os: map['os'] as String? ?? 'unknown',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActiveAt: (map['lastActiveAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceName': deviceName,
      'os': os,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActiveAt': Timestamp.fromDate(lastActiveAt),
    };
  }
}
