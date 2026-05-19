import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session_model.dart';

class SessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _sessionKey = 'swarn_khata_session_id';

  Future<Map<String, String>> getCurrentDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    String deviceName = 'Unknown Device';
    String os = 'unknown';

    try {
      if (kIsWeb) {
        deviceName = 'Web Browser';
        os = 'web';
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceName = '${androidInfo.brand} ${androidInfo.model}';
        os = 'android';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceName = iosInfo.name;
        os = 'ios';
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        deviceName = windowsInfo.computerName;
        os = 'windows';
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfo.macOsInfo;
        deviceName = macInfo.computerName;
        os = 'macos';
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        deviceName = linuxInfo.name;
        os = 'linux';
      }
    } catch (e) {
      if (Platform.isAndroid) os = 'android';
      if (Platform.isIOS) os = 'ios';
      if (Platform.isWindows) os = 'windows';
      if (Platform.isMacOS) os = 'macos';
      if (Platform.isLinux) os = 'linux';
    }

    return {
      'deviceName': deviceName,
      'os': os,
    };
  }

  Future<String?> getLocalSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey);
  }

  Future<void> clearLocalSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<bool> registerOrUpdateSession(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    String? sessionId = prefs.getString(_sessionKey);
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('sessions');

    final info = await getCurrentDeviceInfo();

    if (sessionId == null) {
      final rand = Random().nextInt(100000).toString().padLeft(5, '0');
      sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}_$rand';
      await prefs.setString(_sessionKey, sessionId);

      final session = SessionModel(
        id: sessionId,
        deviceName: info['deviceName']!,
        os: info['os']!,
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
      );

      await docRef.doc(sessionId).set(session.toMap());
      return true;
    } else {
      final doc = await docRef.doc(sessionId).get();
      if (!doc.exists) {
        await prefs.remove(_sessionKey);
        return false; 
      } else {
        await docRef.doc(sessionId).update({
          'lastActiveAt': FieldValue.serverTimestamp(),
        });
        return true;
      }
    }
  }

  Stream<List<SessionModel>> getSessionsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('sessions')
        .orderBy('lastActiveAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return SessionModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> deleteSession(String userId, String sessionId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('sessions')
        .doc(sessionId)
        .delete();
  }
}
