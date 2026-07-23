import '../models/emergency_contact.dart';
import '../models/location_data.dart';

class SmsService {
  const SmsService();

  Future<void> sendEmergencyMessage({
    required List<EmergencyContact> contacts,
    required LocationData location,
  }) async {
    final message = _buildEmergencyMessage(location);

    for (final contact in contacts) {
      // TODO: Integrate flutter_sms or telephony package.
      // This is currently a placeholder.

      print(
        '''
Sending SMS

To      : ${contact.name}
Number  : ${contact.phoneNumber}

$message
''',
      );
    }
  }

  String _buildEmergencyMessage(LocationData location) {
    return '''
🚨 CONNECTSAFE EMERGENCY ALERT 🚨

I may be in danger and need immediate assistance.

My current location:

Latitude : ${location.latitude}
Longitude: ${location.longitude}

Google Maps:
https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}

Please contact me or emergency services immediately.
''';
  }
}