import '../models/emergency_event.dart';

class EmergencyHistoryService {
  EmergencyHistoryService();

  final List<EmergencyEvent> _history = [];

  List<EmergencyEvent> get history =>
      List.unmodifiable(_history);

  Future<void> saveEmergencyEvent(
    EmergencyEvent event,
  ) async {
    _history.insert(0, event);
  }

  Future<List<EmergencyEvent>> getEmergencyHistory() async {
    return List.unmodifiable(_history);
  }

  Future<EmergencyEvent?> getEmergencyById(
    String id,
  ) async {
    try {
      return _history.firstWhere(
        (event) => event.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteEmergencyEvent(
    String id,
  ) async {
    _history.removeWhere(
      (event) => event.id == id,
    );
  }

  Future<void> clearHistory() async {
    _history.clear();
  }

  Future<int> getTotalEmergencyCount() async {
    return _history.length;
  }

  Future<bool> hasEmergencyHistory() async {
    return _history.isNotEmpty;
  }
}