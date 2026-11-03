
import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class MeshService {
MeshService._();

static final MeshService instance = MeshService._();

final List<ScanResult> discoveredDevices = [];

StreamSubscription<List<ScanResult>>? _scanSubscription;

BluetoothDevice? connectedDevice;

BluetoothCharacteristic? _writeCharacteristic;
BluetoothCharacteristic? _notifyCharacteristic;

// ============================================================
// SCAN
// ============================================================

Future<void> startScan({
Duration timeout = const Duration(seconds: 10),
void Function(List<ScanResult>)? onDevicesUpdated,
}) async {
discoveredDevices.clear();

final adapterState =
await FlutterBluePlus.adapterState.first;

if (adapterState != BluetoothAdapterState.on) {
throw Exception(
'Bluetooth is turned off. Please enable Bluetooth.',
);
}

await _scanSubscription?.cancel();

_scanSubscription =
FlutterBluePlus.scanResults.listen((results) {
discoveredDevices.clear();
discoveredDevices.addAll(results);

onDevicesUpdated?.call(
List.unmodifiable(discoveredDevices),
);
});

await FlutterBluePlus.startScan(
timeout: timeout,
);
}

// ============================================================
// STOP SCAN
// ============================================================

Future<void> stopScan() async {
await FlutterBluePlus.stopScan();

await _scanSubscription?.cancel();
_scanSubscription = null;
}

// ============================================================
// CONNECT
// ============================================================

Future<void> connectToDevice(
BluetoothDevice device,
) async {
await stopScan();

try {
if (connectedDevice != null &&
connectedDevice!.remoteId != device.remoteId) {
try {
await connectedDevice!.disconnect();
} catch (_) {}
}

await device.connect(
timeout: const Duration(seconds: 15),
autoConnect: false,
);

connectedDevice = device;

// Discover services.
await _discoverServices(device);
} catch (e) {
connectedDevice = null;

throw Exception(
'Could not connect to device: $e',
);
}
}

// ============================================================
// DISCOVER SERVICES
// ============================================================

Future<void> _discoverServices(
BluetoothDevice device,
) async {
final services =
await device.discoverServices();

_writeCharacteristic = null;
_notifyCharacteristic = null;

for (final service in services) {
for (final characteristic
in service.characteristics) {

// Characteristic used to SEND data.
if (characteristic.properties.write ||
characteristic.properties.writeWithoutResponse) {
_writeCharacteristic =
characteristic;
}

// Characteristic used to RECEIVE data.
if (characteristic.properties.notify ||
characteristic.properties.indicate) {
_notifyCharacteristic =
characteristic;
}
}
}

if (_writeCharacteristic == null) {
throw Exception(
'No writable BLE characteristic found.',
);
}

// Listen for incoming messages.
if (_notifyCharacteristic != null) {
await _notifyCharacteristic!.setNotifyValue(true);

_notifyCharacteristic!.lastValueStream
    .listen((value) {
if (value.isEmpty) {
return;
}

try {
final message =
utf8.decode(value);

print(
'BLE MESSAGE RECEIVED: $message',
);
} catch (e) {
print(
'Failed to decode BLE message: $e',
);
}
});
}
}

// ============================================================
// SEND MESSAGE
// ============================================================

Future<void> sendMessage(
Map<String, dynamic> message,
) async {
if (connectedDevice == null) {
throw Exception(
'No BLE device connected.',
);
}

if (_writeCharacteristic == null) {
throw Exception(
'No writable BLE characteristic available.',
);
}

final jsonMessage =
jsonEncode(message);

final data =
utf8.encode(jsonMessage);

await _writeCharacteristic!.write(
data,
withoutResponse:
_writeCharacteristic!
    .properties
    .writeWithoutResponse,
);

print(
'BLE MESSAGE SENT: $jsonMessage',
);
}

// ============================================================
// DISCONNECT
// ============================================================

Future<void> disconnect() async {
if (connectedDevice == null) {
return;
}

try {
await connectedDevice!.disconnect();
} catch (_) {}

connectedDevice = null;
_writeCharacteristic = null;
_notifyCharacteristic = null;
}

// ============================================================
// CONNECTION STATUS
// ============================================================

bool get isConnected {
return connectedDevice != null;
}

// ============================================================
// DISPOSE
// ============================================================

Future<void> dispose() async {
await stopScan();
await disconnect();
}
}

