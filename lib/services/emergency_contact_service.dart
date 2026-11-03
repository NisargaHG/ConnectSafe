import 'api_service.dart';

class EmergencyContactService {
  EmergencyContactService._();

  static final EmergencyContactService instance =
  EmergencyContactService._();

  final ApiService _api = ApiService.instance;

  Future<List<dynamic>> getContacts() async {
    final result = await _api.get('emergency-contacts/');

    return List<dynamic>.from(result);
  }

  Future<Map<String, dynamic>> addContact({
    required String name,
    required String phone,
    required String relationship,
  }) async {
    return await _api.post(
      'emergency-contacts/',
      {
        'name': name,
        'phone': phone,
        'relationship': relationship,
      },
    );
  }

  Future<Map<String, dynamic>> updateContact({
    required int id,
    required String name,
    required String phone,
    required String relationship,
  }) async {
    return await _api.put(
      'emergency-contacts/$id/',
      {
        'name': name,
        'phone': phone,
        'relationship': relationship,
      },
    );
  }
  Future<Map<String, dynamic>> deleteContact(int id) async {
    return await _api.delete(
      'emergency-contacts/$id/',
    );
  }
}