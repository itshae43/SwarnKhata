import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarn_khata/core/models/party_model.dart';
import 'package:swarn_khata/core/services/party_service.dart';
import 'package:swarn_khata/features/auth/providers/auth_providers.dart';

// ─── PARTY SERVICE PROVIDER ──────────────────────────────────────────
final partyServiceProvider = Provider<PartyService>((ref) => PartyService());

// ─── PARTIES STREAM PROVIDER ─────────────────────────────────────────
final partiesStreamProvider = StreamProvider<List<PartyModel>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);
  
  return ref.watch(partyServiceProvider).partiesStream(user.uid);
});

// ─── PARTY NOTIFIER STATE ────────────────────────────────────────────
class PartyState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const PartyState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  PartyState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
    bool clearError = false,
  }) {
    return PartyState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

// ─── PARTY NOTIFIER ──────────────────────────────────────────────────
class PartyNotifier extends Notifier<PartyState> {
  @override
  PartyState build() => const PartyState();

  PartyService get _partyService => ref.read(partyServiceProvider);

  Future<String?> createParty({
    required String name,
    required String type,
    required String phone,
    required String address,
    required String email,
    required double cashBalance,
    required double goldBalance,
    required double diamondBalance,
  }) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) {
      state = state.copyWith(error: 'User not authenticated');
      return null;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final now = DateTime.now();
      final party = PartyModel(
        id: '', // Firestore will generate this
        userId: user.uid,
        name: name,
        type: type,
        phone: phone,
        email: email,
        address: address,
        cashBalance: cashBalance,
        goldBalanceGrams: goldBalance,
        silverBalanceGrams: 0.0, // Default for now
        diamondBalanceCarats: diamondBalance,
        createdAt: now,
        updatedAt: now,
      );

      final newId = await _partyService.createParty(party);
      state = state.copyWith(isLoading: false, isSuccess: true);
      return newId;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  void reset() {
    state = const PartyState();
  }
}

// ─── PARTY NOTIFIER PROVIDER ─────────────────────────────────────────
final partyNotifierProvider = NotifierProvider<PartyNotifier, PartyState>(PartyNotifier.new);
