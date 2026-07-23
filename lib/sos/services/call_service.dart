import 'package:flutter/foundation.dart';

class CallService {
  static const String emergencyNumber = '112';

  Future<bool> callEmergency() async {
    try {
      // TODO:
      // Integrate url_launcher or platform-specific phone call logic.
      debugPrint('Calling emergency number: $emergencyNumber');
      return true;
    } catch (e) {
      debugPrint('Call failed: $e');
      return false;
    }
  }

  Future<bool> callNumber(String phoneNumber) async {
    try {
      debugPrint('Calling: $phoneNumber');
      return true;
    } catch (e) {
      debugPrint('Call failed: $e');
      return false;
    }
  }
}