import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reminder_model.dart';

class ReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ReminderModel>> getReminders(String userId) {
    return _firestore
        .collection('reminders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReminderModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<List<ReminderModel>> getPartyReminders(String partyId) {
    return _firestore
        .collection('reminders')
        .where('partyId', isEqualTo: partyId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReminderModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> createReminder(ReminderModel reminder) async {
    await _firestore.collection('reminders').add(reminder.toMap());
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    await _firestore
        .collection('reminders')
        .doc(reminder.id)
        .update(reminder.toMap());
  }

  Future<void> deleteReminder(String id) async {
    await _firestore.collection('reminders').doc(id).delete();
  }

  Future<void> markAsDone(String id) async {
    await _firestore
        .collection('reminders')
        .doc(id)
        .update({'status': ReminderStatus.completed.name});
  }
}
