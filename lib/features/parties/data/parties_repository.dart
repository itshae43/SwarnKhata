import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final partiesRepositoryProvider = Provider<PartiesRepository>((ref) {
  return PartiesRepository(FirebaseFirestore.instance);
});

class PartiesRepository {
  final FirebaseFirestore _firestore;

  PartiesRepository(this._firestore);

  // Get all parties for a specific user
  Stream<List<Map<String, dynamic>>> getUserParties(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('parties')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Add a new party
  Future<void> addParty(String userId, Map<String, dynamic> partyData) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('parties')
        .add(partyData);
  }

  // Get transactions for a specific party
  Stream<List<Map<String, dynamic>>> getPartyTransactions(String userId, String partyId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('parties')
        .doc(partyId)
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Add a transaction
  Future<void> addTransaction(String userId, String partyId, Map<String, dynamic> transactionData) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('parties')
        .doc(partyId)
        .collection('transactions')
        .add({
      ...transactionData,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
