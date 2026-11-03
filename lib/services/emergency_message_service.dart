import 'api_service.dart';

class EmergencyMessageService {
  EmergencyMessageService._();

  static final EmergencyMessageService instance =
  EmergencyMessageService._();

  final ApiService _api = ApiService.instance;

  Future<Map<String, dynamic>> createMessage({
    required String message,
    required double latitude,
    required double longitude,
    required String priority,
    required String emergencyType,
    required List<int> contactIds,

  }) async {
    return await _api.post(
      'sos/',
      {
        'message': message,
        'latitude': latitude,
        'longitude': longitude,
        'priority': priority,
        'emergency_type': emergencyType,
        'contact_ids': contactIds,
      },
    );
  }

  Future<List<dynamic>> getMessages() async {
    final response = await _api.get('messages/');

    return List<dynamic>.from(response);
  }
}