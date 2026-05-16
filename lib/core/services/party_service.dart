import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/party_model.dart';

class PartyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── PARTIES COLLECTION REFERENCE ──────────────────────────────────
  CollectionReference<Map<String, dynamic>> _partiesRef(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('parties');
  }

  // ─── CREATE PARTY ──────────────────────────────────────────────────
  Future<String> createParty(PartyModel party) async {
    final docRef = await _partiesRef(party.userId).add(party.toMap());
    return docRef.id;
  }

  // ─── GET PARTIES STREAM ─────────────────────────────────────────────
  Stream<List<PartyModel>> partiesStream(String userId) {
    return _partiesRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return PartyModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // ─── UPDATE PARTY ──────────────────────────────────────────────────
  Future<void> updateParty(PartyModel party) async {
    await _partiesRef(party.userId).doc(party.id).update(party.toMap());
  }

  // ─── DELETE PARTY ──────────────────────────────────────────────────
  Future<void> deleteParty(String userId, String partyId) async {
    await _partiesRef(userId).doc(partyId).delete();
  }
}
