import '../models/emergency_contact.dart';

class ContactService {
  final List<EmergencyContact> _contacts = [];

  List<EmergencyContact> get contacts =>
      List.unmodifiable(_contacts);

  void addContact(EmergencyContact contact) {
    _contacts.add(contact);
  }

  void updateContact(
      int index,
      EmergencyContact contact,
      ) {
    if (index >= 0 && index < _contacts.length) {
      _contacts[index] = contact;
    }
  }

  void removeContact(int index) {
    if (index >= 0 && index < _contacts.length) {
      _contacts.removeAt(index);
    }
  }

  EmergencyContact? get primaryContact {
    try {
      return _contacts.firstWhere(
            (c) => c.isPrimary,
      );
    } catch (_) {
      return null;
    }
  }

  bool get hasContacts => _contacts.isNotEmpty;

  void clearContacts() {
    _contacts.clear();
  }
}