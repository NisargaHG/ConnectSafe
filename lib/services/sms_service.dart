import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SmsService {
  SmsService._();

  static final SmsService instance = SmsService._();

  static const MethodChannel _channel =
  MethodChannel('connectsafe/sms');

  Future<bool> sendSMS({
    required String phone,
    required String message,
  }) async {
    try {
      debugPrint('Sending SMS directly to: $phone');

      final bool result = await _channel.invokeMethod(
        'sendSMS',
        {
          'phone': phone,
          'message': message,
        },
      );

      debugPrint('SMS result: $result');

      return result;
    } on PlatformException catch (e) {
      debugPrint(
        'SMS failed: ${e.code} - ${e.message}',
      );
      return false;
    } catch (e) {
      debugPrint('SMS failed: $e');
      return false;
    }
  }
}