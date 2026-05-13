import 'package:cloud_firestore/cloud_firestore.dart';

class PartyModel {
  final String id;
  final String userId; // owner user id
  final String name;
  final String type; // 'Retail Customer', 'B2B Supplier', 'Karigar', 'Other'
  final String phone;
  final String email;
  final String address;
  final double cashBalance; // positive = they owe, negative = you owe
  final double goldBalanceGrams; // positive = they owe, negative = you owe
  final double silverBalanceGrams;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PartyModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.phone,
    required this.email,
    required this.address,
    required this.cashBalance,
    required this.goldBalanceGrams,
    required this.silverBalanceGrams,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PartyModel.fromMap(String id, Map<String, dynamic> map) {
    return PartyModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      type: map['type'] as String? ?? 'Other',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      address: map['address'] as String? ?? '',
      cashBalance: (map['cashBalance'] as num?)?.toDouble() ?? 0.0,
      goldBalanceGrams: (map['goldBalanceGrams'] as num?)?.toDouble() ?? 0.0,
      silverBalanceGrams: (map['silverBalanceGrams'] as num?)?.toDouble() ?? 0.0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'type': type,
      'phone': phone,
      'email': email,
      'address': address,
      'cashBalance': cashBalance,
      'goldBalanceGrams': goldBalanceGrams,
      'silverBalanceGrams': silverBalanceGrams,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Dr = positive balance (they owe you cash)
  String get cashBalanceLabel {
    if (cashBalance > 0) return 'Dr (To Receive)';
    if (cashBalance < 0) return 'Cr (To Pay)';
    return 'Settled';
  }

  String get goldBalanceLabel {
    if (goldBalanceGrams > 0) return 'Dr (To Receive)';
    if (goldBalanceGrams < 0) return 'Cr (To Give)';
    return 'Settled';
  }
}
