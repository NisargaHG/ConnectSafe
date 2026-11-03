import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../services/mesh_service.dart';
import '../../services/ble_advertiser_service.dart';

class MeshTestScreen extends StatefulWidget {
  const MeshTestScreen({super.key});

  @override
  State<MeshTestScreen> createState() => _MeshTestScreenState();
}

class _MeshTestScreenState extends State<MeshTestScreen> {
  final MeshService meshService = MeshService.instance;

  final BleAdvertiserService bleAdvertiser =
      BleAdvertiserService.instance;

  List<ScanResult> devices = [];

  bool scanning = false;
  bool advertising = false;

  String status = 'Ready';

  // ============================================================
  // START BLE ADVERTISING
  // ============================================================

  Future<void> startAdvertising() async {
    setState(() {
      status = 'Checking BLE advertising support...';
    });

    try {
      final supported =
      await bleAdvertiser.isAdvertisingSupported();

      if (!supported) {
        if (!mounted) return;

        setState(() {
          status =
          'BLE advertising is not supported on this phone.';
        });

        return;
      }

      final started =
      await bleAdvertiser.startAdvertising();

      if (!mounted) return;

      if (started) {
        setState(() {
          advertising = true;
          status = 'ConnectSafe BLE advertising started';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This phone is now advertising ConnectSafe BLE.',
            ),
          ),
        );
      } else {
        setState(() {
          status = 'Could not start BLE advertising';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        status = 'Advertising error: $e';
      });
    }
  }

  // ============================================================
  // STOP BLE ADVERTISING
  // ============================================================

  Future<void> stopAdvertising() async {
    try {
      await bleAdvertiser.stopAdvertising();

      if (!mounted) return;

      setState(() {
        advertising = false;
        status = 'BLE advertising stopped';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        status = 'Stop advertising error: $e';
      });
    }
  }

  // ============================================================
  // SCAN
  // ============================================================

  Future<void> scanForDevices() async {
    setState(() {
      scanning = true;
      devices = [];
      status = 'Scanning for nearby devices...';
    });

    try {
      await meshService.startScan(
        timeout: const Duration(seconds: 10),
        onDevicesUpdated: (results) {
          if (!mounted) return;

          setState(() {
            devices = results;
          });
        },
      );

      if (!mounted) return;

      setState(() {
        scanning = false;
        status = 'Scan completed';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        scanning = false;
        status = 'Scan error: $e';
      });
    }
  }

  // ============================================================
  // STOP SCAN
  // ============================================================

  Future<void> stopScan() async {
    await meshService.stopScan();

    if (!mounted) return;

    setState(() {
      scanning = false;
      status = 'Scan stopped';
    });
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    meshService.dispose();

    if (advertising) {
      bleAdvertiser.stopAdvertising();
    }

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesh Network Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ====================================================
            // STATUS
            // ====================================================

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      advertising
                          ? Icons.bluetooth_connected
                          : scanning
                          ? Icons.bluetooth_searching
                          : Icons.bluetooth,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        status,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ====================================================
            // ADVERTISING BUTTON
            // ====================================================

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: advertising
                    ? stopAdvertising
                    : startAdvertising,
                icon: Icon(
                  advertising
                      ? Icons.stop
                      : Icons.wifi_tethering,
                ),
                label: Text(
                  advertising
                      ? 'Stop Advertising'
                      : 'Start BLE Advertising',
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ====================================================
            // SCAN BUTTON
            // ====================================================

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: scanning
                    ? stopScan
                    : scanForDevices,
                icon: Icon(
                  scanning
                      ? Icons.stop
                      : Icons.search,
                ),
                label: Text(
                  scanning
                      ? 'Stop Scan'
                      : 'Scan Nearby Devices',
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ====================================================
            // DEVICE COUNT
            // ====================================================

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Nearby devices: ${devices.length}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ====================================================
            // DEVICE LIST
            // ====================================================

            Expanded(
              child: devices.isEmpty
                  ? const Center(
                child: Text(
                  'No BLE devices found yet.',
                  textAlign: TextAlign.center,
                ),
              )
                  : ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];

                  final name =
                  device.device.platformName.isNotEmpty
                      ? device.device.platformName
                      : 'Unknown Device';

                  return Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.phone_android,
                      ),
                      title: Text(name),
                      subtitle: Text(
                        '${device.device.remoteId}\n'
                            'Signal: ${device.rssi} dBm',
                      ),
                      isThreeLine: true,
                      onTap: () async {
                        setState(() {
                          status =
                          'Connecting to $name...';
                        });

                        try {
                          await meshService
                              .connectToDevice(
                            device.device,
                          );

                          if (!mounted) return;

                          setState(() {
                            status =
                            'Connected to $name';
                          });

                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            SnackBar(
                              content: Text(
                                'Connected to $name',
                              ),
                            ),
                          );
                        } catch (e) {
                          if (!mounted) return;

                          setState(() {
                            status =
                            'Connection failed';
                          });

                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            SnackBar(
                              content: Text(
                                'Connection failed: $e',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}