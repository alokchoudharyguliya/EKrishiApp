import 'package:url_launcher/url_launcher.dart';

/// Launch WhatsApp with a pre-filled message
/// 
/// [phoneNumber] should be 10 digits (without country code)
/// [message] is the message to send
Future<void> launchWhatsAppOrder(String phoneNumber, String message) async {
  try {
    // Remove any non-digit characters and ensure 10 digits
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '').substring(
        phoneNumber.replaceAll(RegExp(r'\D'), '').length >= 10
            ? phoneNumber.replaceAll(RegExp(r'\D'), '').length - 10
            : 0);

    if (cleanPhone.length != 10) {
      throw Exception('Invalid phone number. Must be 10 digits.');
    }

    // WhatsApp uses country code 91 for India
    const countryCode = '91';
    final fullPhoneNumber = countryCode + cleanPhone;

    // Encode message for URL
    final encodedMessage = Uri.encodeComponent(message);

    // Generate WhatsApp URL
    final url = Uri.parse('https://wa.me/$fullPhoneNumber?text=$encodedMessage');

    // Launch URL
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch WhatsApp. Make sure WhatsApp is installed.');
    }
  } catch (e) {
    print('Error launching WhatsApp: $e');
    rethrow;
  }
}




