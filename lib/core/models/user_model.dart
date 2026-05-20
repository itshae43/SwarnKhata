import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String businessName;
  final String email;
  final String phone;
  final String photoUrl;
  final String authProvider; // 'email', 'google', 'phone'
  final DateTime createdAt;
  final DateTime updatedAt;
  final String role;
  final bool isLoggedIn;

  const UserModel({
    required this.uid,
    required this.fullName,
    required this.businessName,
    required this.email,
    required this.phone,
    required this.photoUrl,
    required this.authProvider,
    required this.createdAt,
    required this.updatedAt,
    this.role = 'user',
    this.isLoggedIn = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      businessName: map['businessName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      photoUrl: map['photoUrl'] as String? ?? '',
      authProvider: map['authProvider'] as String? ?? 'email',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      role: map['role'] as String? ?? 'user',
      isLoggedIn: map['isLoggedIn'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'businessName': businessName,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'authProvider': authProvider,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'role': role,
      'isLoggedIn': isLoggedIn,
    };
  }

  UserModel copyWith({
    String? uid,
    String? fullName,
    String? businessName,
    String? email,
    String? phone,
    String? photoUrl,
    String? authProvider,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? role,
    bool? isLoggedIn,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      businessName: businessName ?? this.businessName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      authProvider: authProvider ?? this.authProvider,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      role: role ?? this.role,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}
