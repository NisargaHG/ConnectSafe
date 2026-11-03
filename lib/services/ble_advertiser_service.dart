import 'package:flutter/services.dart';

class BleAdvertiserService {
  BleAdvertiserService._();

  static final BleAdvertiserService instance =
  BleAdvertiserService._();

  static const MethodChannel _channel =
  MethodChannel('connectsafe/ble');

  Future<bool> isAdvertisingSupported() async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'isAdvertisingSupported',
      );

      return result ?? false;
    } on PlatformException catch (e) {
      print('BLE support check failed: ${e.message}');
      return false;
    }
  }

  Future<bool> startAdvertising() async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'startAdvertising',
      );

      return result ?? false;
    } on PlatformException catch (e) {
      print('BLE advertising failed: ${e.message}');
      return false;
    }
  }

  Future<bool> stopAdvertising() async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'stopAdvertising',
      );

      return result ?? false;
    } on PlatformException catch (e) {
      print('BLE advertising stop failed: ${e.message}');
      return false;
    }
  }
}