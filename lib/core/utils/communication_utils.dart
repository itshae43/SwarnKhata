import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class CommunicationUtils {
  static Future<void> makeCall(String phoneNumber) async {
    if (phoneNumber.trim().isEmpty) return;
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri launchUri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  static Future<void> sendSMS(String phoneNumber) async {
    if (phoneNumber.trim().isEmpty) return;
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri launchUri = Uri.parse('sms:$cleanPhone');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  static Future<void> launchWhatsApp(String phoneNumber, String message) async {
    if (phoneNumber.trim().isEmpty) return;
    // Remove non-numeric characters
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    
    final Uri whatsappUri;
    if (Platform.isAndroid) {
      whatsappUri = Uri.parse("whatsapp://send?phone=$cleanPhone&text=${Uri.encodeComponent(message)}");
    } else {
      whatsappUri = Uri.parse("https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}");
    }

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      // Fallback to web if app is not installed
      final webUri = Uri.parse("https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}");
      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    }
  }
}
