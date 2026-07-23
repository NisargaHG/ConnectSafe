import '../models/emergency_contact.dart';
import 'contact_service.dart';

class EmergencyService {
  EmergencyService({
    required ContactService contactService,
  }) : _contactService = contactService;

  final ContactService _contactService;

  Future<void> triggerEmergency() async {
    // 1. Get current location
    // await _getLocation();

    // 2. Notify emergency contacts
    await _notifyContacts();

    // 3. Store emergency event
    // await _saveEmergency();

    // 4. Notify AI assistant
    // await _startAIAssistant();
  }

  Future<void> _notifyContacts() async {
    final List<EmergencyContact> contacts =
        _contactService.contacts;

    for (final contact in contacts) {
      // SMS/Call implementation will be added later.
      print(
        'Emergency alert sent to ${contact.name} (${contact.phoneNumber})',
      );
    }
  }
}