import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swarn_khata/core/models/transaction_model.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createTransaction(TransactionModel transaction) async {
    final docRef = _firestore.collection('transactions').doc();
    final newTransaction = TransactionModel(
      id: docRef.id,
      userId: transaction.userId,
      partyId: transaction.partyId,
      partyName: transaction.partyName,
      partyPhone: transaction.partyPhone,
      type: transaction.type,
      paymentMode: transaction.paymentMode,
      cashAmount: transaction.cashAmount,
      metalType: transaction.metalType,
      metalWeight: transaction.metalWeight,
      metalPurity: transaction.metalPurity,
      notes: transaction.notes,
      date: transaction.date,
      createdAt: transaction.createdAt,
    );
    await docRef.set(newTransaction.toMap());
  }

  Stream<List<TransactionModel>> transactionsStream(String userId) {
    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final transactions = snapshot.docs
              .map((doc) => TransactionModel.fromMap(doc.id, doc.data()))
              .toList();
          transactions.sort((a, b) => b.date.compareTo(a.date));
          return transactions;
        });
  }

  Stream<List<TransactionModel>> partyTransactionsStream(String userId, String partyId) {
    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .where('partyId', isEqualTo: partyId)
        .snapshots()
        .map((snapshot) {
          final transactions = snapshot.docs
              .map((doc) => TransactionModel.fromMap(doc.id, doc.data()))
              .toList();
          transactions.sort((a, b) => b.date.compareTo(a.date));
          return transactions;
        });
  }
}
