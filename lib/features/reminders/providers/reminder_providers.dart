import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarn_khata/core/models/reminder_model.dart';
import 'package:swarn_khata/core/services/reminder_service.dart';
import 'package:swarn_khata/features/auth/providers/auth_providers.dart';

final reminderServiceProvider = Provider((ref) => ReminderService());

final remindersStreamProvider = StreamProvider<List<ReminderModel>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(reminderServiceProvider).getReminders(user.uid);
});

final partyRemindersStreamProvider = StreamProvider.family<List<ReminderModel>, String>((ref, partyId) {
  return ref.watch(reminderServiceProvider).getPartyReminders(partyId);
});

class ReminderNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> createReminder({
    required String partyId,
    required String partyName,
    required String partyPhone,
    required String title,
    required String note,
    required DateTime date,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(currentUserProvider).value;
      if (user == null) throw Exception('User not logged in');

      final reminder = ReminderModel(
        id: '',
        userId: user.uid,
        partyId: partyId,
        partyName: partyName,
        partyPhone: partyPhone,
        title: title,
        note: note,
        date: date,
        status: ReminderStatus.upcoming,
        createdAt: DateTime.now(),
      );

      await ref.read(reminderServiceProvider).createReminder(reminder);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(reminderServiceProvider).updateReminder(reminder);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsDone(String id) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(reminderServiceProvider).markAsDone(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteReminder(String id) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(reminderServiceProvider).deleteReminder(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final reminderNotifierProvider = NotifierProvider<ReminderNotifier, AsyncValue<void>>(ReminderNotifier.new);
