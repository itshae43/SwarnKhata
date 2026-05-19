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

    final partyDocRef = _firestore
        .collection('users')
        .doc(transaction.userId)
        .collection('parties')
        .doc(transaction.partyId);

    await _firestore.runTransaction((txn) async {
      final partySnapshot = await txn.get(partyDocRef);
      if (partySnapshot.exists) {
        final partyData = partySnapshot.data()!;
        double cashBalance = (partyData['cashBalance'] as num?)?.toDouble() ?? 0.0;
        double goldBalance = (partyData['goldBalanceGrams'] as num?)?.toDouble() ?? 0.0;
        double diamondBalance = (partyData['diamondBalanceCarats'] as num?)?.toDouble() ?? 0.0;

        final isDebit = transaction.type == TransactionType.payment ||
            transaction.type == TransactionType.sale ||
            transaction.type == TransactionType.metalOut;

        final isCredit = transaction.type == TransactionType.receipt ||
            transaction.type == TransactionType.purchase ||
            transaction.type == TransactionType.metalIn ||
            transaction.type == TransactionType.return_;

        if (transaction.metalType.isEmpty) {
          if (isDebit) cashBalance += transaction.cashAmount;
          if (isCredit) cashBalance -= transaction.cashAmount;
        } else if (transaction.metalType == 'gold') {
          if (isDebit) goldBalance += transaction.metalWeight;
          if (isCredit) goldBalance -= transaction.metalWeight;
        } else if (transaction.metalType == 'diamond') {
          if (isDebit) diamondBalance += transaction.metalWeight;
          if (isCredit) diamondBalance -= transaction.metalWeight;
        }

        txn.update(partyDocRef, {
          'cashBalance': cashBalance,
          'goldBalanceGrams': goldBalance,
          'diamondBalanceCarats': diamondBalance,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      txn.set(docRef, newTransaction.toMap());
    });
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
