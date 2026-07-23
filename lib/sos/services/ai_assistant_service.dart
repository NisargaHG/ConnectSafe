import '../models/emergency_event.dart';
import '../models/location_data.dart';

class AIAssistantService {
  const AIAssistantService();

  Future<String> generateEmergencyAdvice({
    required LocationData location,
  }) async {
    // TODO:
    // Replace with Gemini API integration.

    return '''
Stay as calm as possible.

• Move to a safe, well-lit area if you can.
• Keep your phone unlocked and charged.
• Share your live location with trusted contacts.
• Call your local emergency services if you are in immediate danger.
• Avoid confronting any potential threat.
''';
  }

  Future<String> generateEmergencySummary({
    required EmergencyEvent event,
  }) async {
    // TODO:
    // Generate AI summary using Gemini.

    return '''
Emergency Summary

Status: ${event.status}

Time:
${event.triggeredAt}

Location:
Latitude: ${event.location.latitude}
Longitude: ${event.location.longitude}

Contacts Notified:
${event.notifiedContacts.length}

SMS Sent:
${event.smsSent ? "Yes" : "No"}

Calls Placed:
${event.callsPlaced ? "Yes" : "No"}

AI Assistance:
${event.aiActivated ? "Active" : "Inactive"}
''';
  }

  Future<List<String>> getSafetyTips() async {
    // TODO:
    // Replace with AI-generated personalized tips.

    return [
      'Stay calm and assess your surroundings.',
      'Move toward a populated or well-lit area.',
      'Keep your phone charged.',
      'Share your location with trusted contacts.',
      'Avoid isolated routes whenever possible.',
      'Call emergency services if you are in immediate danger.',
    ];
  }

  Future<bool> isGeminiConfigured() async {
    // TODO:
    // Check whether Gemini API has been configured.

    return false;
  }
}