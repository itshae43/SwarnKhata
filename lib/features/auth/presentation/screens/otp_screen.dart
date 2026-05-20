import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swarn_khata/core/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swarn_khata/features/auth/providers/auth_providers.dart';
import 'package:swarn_khata/features/navigation/presentation/providers/navigation_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen>
    with SingleTickerProviderStateMixin {
  String _selectedRole = 'admin'; // 'admin' or 'other'
  final List<TextEditingController> _pinControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _pinFocusNodes = List.generate(6, (_) => FocusNode());
  String get _enteredPin =>
      _pinControllers.map((c) => c.text).join();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  StreamSubscription? _requestSub;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _requestSub?.cancel();
    for (final c in _pinControllers) { c.dispose(); }
    for (final f in _pinFocusNodes) { f.dispose(); }
    super.dispose();
  }

  void _listenToRequest(String requestId, UserModel user) {
    _requestSub?.cancel();
    _requestSub = FirebaseFirestore.instance
        .collection('login_requests')
        .doc(requestId)
        .snapshots()
        .listen((doc) async {
      if (doc.exists) {
        final status = doc.data()?['status'];
        if (status == 'approved') {
          _requestSub?.cancel();
          if (mounted && Navigator.canPop(context)) {
            Navigator.pop(context); // Close the waiting dialog
          }
          _showSnack('Request Approved! Logging in...');
          final success = await ref.read(otpNotifierProvider.notifier).verifyOtp(
            'mock', // Mock OTP
            role: 'other',
            phone: user.phone,
            name: user.fullName,
          );
          if (success && mounted) {
            ref.read(navigationProvider.notifier).setIndex(0);
          }
        } else if (status == 'declined') {
          _requestSub?.cancel();
          if (mounted && Navigator.canPop(context)) {
            Navigator.pop(context); // Close the waiting dialog
          }
          _showSnack('Login Request Declined by Admin.');
          ref.read(otpNotifierProvider.notifier).reset(); // Clear loading state
        }
      }
    });
  }

  void _showWaitingDialog(String requestId, UserModel user) {
    _listenToRequest(requestId, user);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false, // Prevent closing by gesture/back button
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8A7311)),
                      strokeWidth: 4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Waiting for Admin...',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: const Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'A login request for ${user.fullName} has been sent to the admin. Once approved, you will be logged in automatically.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () {
                      _requestSub?.cancel();
                      FirebaseFirestore.instance
                          .collection('login_requests')
                          .doc(requestId)
                          .delete(); // Delete the request if cancelled
                      Navigator.pop(context);
                      _showSnack('Login request cancelled.');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[700],
                      side: BorderSide(color: Colors.red[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      'Cancel Request',
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _verifyAdmin() async {
    final pin = _enteredPin;
    if (pin.length < 6) {
      _showSnack('Please enter all 6 digits of your PIN.');
      return;
    }
    final success =
        await ref.read(otpNotifierProvider.notifier).verifyAdmin(pin: pin);
    if (!success && mounted) {
      // Clear pin on failure
      for (final c in _pinControllers) { c.clear(); }
      _pinFocusNodes.first.requestFocus();
      final error = ref.read(otpNotifierProvider).error;
      _showSnack(error ?? 'Admin verification failed');
    } else if (success && mounted) {
      ref.read(navigationProvider.notifier).setIndex(0);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.montserrat()),
        backgroundColor: const Color(0xFF8A7311),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showAddUserDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Add User Profile',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                style: GoogleFonts.montserrat(),
                decoration: InputDecoration(
                  labelText: 'User Name',
                  labelStyle: GoogleFonts.montserrat(color: const Color(0xFF8A7311)),
                  hintText: 'Enter user name',
                  hintStyle: GoogleFonts.montserrat(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFFD4B13B)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD4B13B), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.montserrat(),
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  labelStyle: GoogleFonts.montserrat(color: const Color(0xFF8A7311)),
                  hintText: 'Enter 10-digit mobile number',
                  hintStyle: GoogleFonts.montserrat(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFFD4B13B)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD4B13B), width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.montserrat(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final phone = phoneController.text.trim();
                if (name.isEmpty) {
                  _showSnack('Please enter user name');
                  return;
                }
                if (phone.isEmpty) {
                  _showSnack('Please enter mobile number');
                  return;
                }
                if (phone.length < 10) {
                  _showSnack('Please enter a valid 10-digit mobile number');
                  return;
                }

                // Normalize phone number (remove spaces, etc.) and prepend country code
                final cleanPhone = phone.replaceAll(RegExp(r'[\s\-()]+'), '');
                final digitsOnly = cleanPhone.replaceAll(RegExp(r'\D'), '');
                if (digitsOnly == '9671900007' || digitsOnly == '919671900007') {
                  _showSnack('Cannot create a user profile with the Admin\'s phone number.');
                  return;
                }
                final fullPhone = cleanPhone.startsWith('+') ? cleanPhone : '+91$cleanPhone';

                Navigator.pop(context);
                final user = await ref.read(otpNotifierProvider.notifier).createNewUser(name, fullPhone);
                if (user != null) {
                  _showSnack('Profile created! Sending login request to admin...');
                  
                  // Automatically send login request to admin
                  ref.read(otpNotifierProvider.notifier).sendLoginRequest(user);
                  
                  // Query for the latest pending request and show the waiting dialog
                  await Future.delayed(const Duration(milliseconds: 600));
                  final qs = await FirebaseFirestore.instance
                      .collection('login_requests')
                      .where('uid', isEqualTo: user.uid)
                      .where('status', isEqualTo: 'pending')
                      .orderBy('timestamp', descending: true)
                      .limit(1)
                      .get();
                  
                  if (qs.docs.isNotEmpty && mounted) {
                    _showWaitingDialog(qs.docs.first.id, user);
                  } else if (mounted) {
                    _showSnack('Failed to initiate login request.');
                  }
                } else {
                  _showSnack('Failed to create user');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D4A1E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Add', style: GoogleFonts.montserrat(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(otpNotifierProvider);
    final otherUsers = ref.watch(userProfilesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ─── ICON ──────────────────────────────────────────
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3D0),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFD4B13B), width: 2),
                    ),
                    child: const Icon(Icons.fingerprint_rounded,
                        color: Color(0xFFD4B13B), size: 40),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome Back',
                    style: GoogleFonts.montserrat(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select your role to continue',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // ─── ROLE SELECTOR ─────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF6EE),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.withOpacity(0.12)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedRole = 'admin';
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedRole == 'admin'
                                    ? const Color(0xFFD4B13B)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Admin',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: _selectedRole == 'admin'
                                      ? Colors.white
                                      : const Color(0xFF8A7311),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedRole = 'other';
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedRole == 'other'
                                    ? const Color(0xFFD4B13B)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Other User',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: _selectedRole == 'other'
                                      ? Colors.white
                                      : const Color(0xFF8A7311),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  if (_selectedRole == 'admin') ...[
                    // ─── ADMIN PIN LABEL ────────────────────────────
                    Text(
                      'Enter Admin PIN',
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF3D3D3D),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Enter your 6-digit admin PIN to continue',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ─── 6-BOX PIN INPUT ────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        return Container(
                          width: 46,
                          height: 56,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: TextField(
                            controller: _pinControllers[index],
                            focusNode: _pinFocusNodes[index],
                            obscureText: true,
                            obscuringCharacter: '●',
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2D4A1E),
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: const Color(0xFFFFF8F0),
                              contentPadding: EdgeInsets.zero,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFFD4B13B), width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFF2D4A1E), width: 2.5),
                              ),
                            ),
                            onChanged: (val) {
                              if (val.isNotEmpty) {
                                // Move to next box
                                if (index < 5) {
                                  _pinFocusNodes[index + 1].requestFocus();
                                } else {
                                  // Last digit — auto-submit
                                  _pinFocusNodes[index].unfocus();
                                  _verifyAdmin();
                                }
                              } else {
                                // Backspace — move to previous
                                if (index > 0) {
                                  _pinFocusNodes[index - 1].requestFocus();
                                }
                              }
                              setState(() {});
                            },
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 28),

                    // ─── SUBMIT BUTTON ──────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton.icon(
                        onPressed: otpState.isLoading ? null : _verifyAdmin,
                        icon: otpState.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : const Icon(Icons.lock_open_rounded,
                                color: Colors.white),
                        label: Text(
                          otpState.isLoading
                              ? 'Verifying PIN...'
                              : 'Login as Admin',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D4A1E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ] else ...[
                    // ─── OTHER USER PROFILES ────────────────────────
                    otherUsers.when(
                      data: (users) {
                        if (users.isEmpty) {
                          return Column(
                            children: [
                              Text(
                                'No profiles found.',
                                style: GoogleFonts.montserrat(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: _showAddUserDialog,
                                icon: const Icon(Icons.person_add_outlined, size: 20),
                                label: const Text('Add New User Profile'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF8A7311),
                                  side: BorderSide(color: const Color(0xFFD4B13B).withOpacity(0.5)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                ),
                              ),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            Container(
                              constraints: const BoxConstraints(maxHeight: 300),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: users.length,
                                separatorBuilder: (context, index) =>
                                    Divider(height: 1, color: Colors.grey[200]),
                                itemBuilder: (context, index) {
                                  final user = users[index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: const Color(0xFFFFF3D0),
                                      child: Text(
                                        user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                                        style: GoogleFonts.montserrat(
                                          color: const Color(0xFFD4B13B),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      user.fullName,
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    trailing: user.isLoggedIn
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.green[50],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'Active',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.green[700],
                                              ),
                                            ),
                                          )
                                        : const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                                    onTap: () async {
                                      if (user.isLoggedIn) {
                                        _showSnack('User ${user.fullName} is already logged in on a device.');
                                        return;
                                      }
                                      
                                      // Show interactive dialog with option to ask for request to access
                                      showDialog(
                                        context: context,
                                        builder: (dialogCtx) {
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            title: Text(
                                              'Request Access',
                                              style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF1E1E1E),
                                              ),
                                            ),
                                            content: Text(
                                              'Would you like to ask for a request to access SwarnKhata for user ${user.fullName}?',
                                              style: GoogleFonts.montserrat(color: Colors.grey[700]),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(dialogCtx),
                                                child: Text(
                                                  'Cancel',
                                                  style: GoogleFonts.montserrat(color: Colors.grey[600]),
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  Navigator.pop(dialogCtx); // Close option dialog
                                                  
                                                  _showSnack('Sending login request to admin...');
                                                  
                                                  // Send Request
                                                  ref.read(otpNotifierProvider.notifier).sendLoginRequest(user);
                                                  
                                                  // Since sendLoginRequest doesn't return the ID, we query for the latest pending request for this user
                                                  await Future.delayed(const Duration(milliseconds: 600));
                                                  final qs = await FirebaseFirestore.instance
                                                      .collection('login_requests')
                                                      .where('uid', isEqualTo: user.uid)
                                                      .where('status', isEqualTo: 'pending')
                                                      .orderBy('timestamp', descending: true)
                                                      .limit(1)
                                                      .get();
                                                  
                                                  if (qs.docs.isNotEmpty && mounted) {
                                                    _showWaitingDialog(qs.docs.first.id, user);
                                                  } else if (mounted) {
                                                    _showSnack('Failed to initiate login request.');
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFF2D4A1E),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                                child: Text(
                                                  'Ask for Access',
                                                  style: GoogleFonts.montserrat(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: _showAddUserDialog,
                              icon: const Icon(Icons.person_add_outlined, size: 20),
                              label: const Text('Add New User Profile'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF8A7311),
                                side: BorderSide(color: const Color(0xFFD4B13B).withOpacity(0.5)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => Container(
                        constraints: const BoxConstraints(maxHeight: 100),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (_, __) => Container(
                        constraints: const BoxConstraints(maxHeight: 100),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('Failed to load profiles'),
                          ),
                        ),
                      ),
                    ),
                  ],

                  // ─── ERROR DISPLAY ─────────────────────────────────
                  if (otpState.error != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: otpState.error!.contains('Waiting') 
                            ? Colors.orange[50] 
                            : const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        otpState.error!,
                        style: GoogleFonts.montserrat(
                          color: otpState.error!.contains('Waiting') 
                              ? Colors.orange[800] 
                              : const Color(0xFFC62828),
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
