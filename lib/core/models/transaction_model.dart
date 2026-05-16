import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { sale, purchase, payment, receipt, metalIn, metalOut, return_ }

enum PaymentMode { cash, online, metal, mixed, upi, rtgs }

class TransactionModel {
  final String id;
  final String userId;
  final String partyId;
  final String partyName;
  final TransactionType type;
  final PaymentMode paymentMode;
  final double cashAmount;
  final String metalType; // 'gold', 'silver', 'diamond', ''
  final double metalWeight;
  final String metalPurity; // '24K', '22K', '18K', ''
  final String notes;
  final DateTime date;
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.partyId,
    required this.partyName,
    required this.type,
    required this.paymentMode,
    required this.cashAmount,
    required this.metalType,
    required this.metalWeight,
    required this.metalPurity,
    required this.notes,
    required this.date,
    required this.createdAt,
  });

  factory TransactionModel.fromMap(String id, Map<String, dynamic> map) {
    return TransactionModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      partyId: map['partyId'] as String? ?? '',
      partyName: map['partyName'] as String? ?? '',
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.sale,
      ),
      paymentMode: PaymentMode.values.firstWhere(
        (e) => e.name == map['paymentMode'],
        orElse: () => PaymentMode.cash,
      ),
      cashAmount: (map['cashAmount'] as num?)?.toDouble() ?? 0.0,
      metalType: map['metalType'] as String? ?? '',
      metalWeight: (map['metalWeight'] as num?)?.toDouble() ?? 0.0,
      metalPurity: map['metalPurity'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'partyId': partyId,
      'partyName': partyName,
      'type': type.name,
      'paymentMode': paymentMode.name,
      'cashAmount': cashAmount,
      'metalType': metalType,
      'metalWeight': metalWeight,
      'metalPurity': metalPurity,
      'notes': notes,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  String get typeLabel {
    switch (type) {
      case TransactionType.sale: return 'Sale';
      case TransactionType.purchase: return 'Purchase';
      case TransactionType.payment: return 'Payment';
      case TransactionType.receipt: return 'Receipt';
      case TransactionType.metalIn: return 'Metal In';
      case TransactionType.metalOut: return 'Metal Out';
      case TransactionType.return_: return 'Return';
    }
  }
}
