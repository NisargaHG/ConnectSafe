import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/constants/app_colors.dart';
import '../../services/emergency_message_service.dart';
import '../../services/emergency_contact_service.dart';
import '../../services/sms_service.dart';


class EmergencyMessageScreen extends StatefulWidget {
  final String emergencyType;
  final String incidentTitle;

  const EmergencyMessageScreen({
    super.key,
    required this.emergencyType,
    required this.incidentTitle,

  });

  @override
  State<EmergencyMessageScreen> createState() =>
      _EmergencyMessageScreenState();
}

class _EmergencyMessageScreenState
    extends State<EmergencyMessageScreen> {
  final TextEditingController messageController =
  TextEditingController();



  String selectedPriority = 'HIGH';

  bool isLoading = false;
  bool isGettingLocation = false;

  List<int> selectedContactIds = [];


  double? latitude;
  double? longitude;
  Future<void> selectEmergencyContacts() async {
    final result = await Navigator.pushNamed(
      context,
      '/select-emergency-contacts',
    );

    if (result != null && result is List<int>) {
      setState(() {
        selectedContactIds = result;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // Automatically get location when screen opens.
    getCurrentLocation();


    // Set default message based on emergency type.
    if (widget.emergencyType == 'FLOOD') {
      messageController.text =
      'I am affected by a flood and need immediate rescue assistance.';
    } else {
      messageController.text =
      'Emergency! I need immediate assistance.';
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // GET CURRENT LOCATION
  // ----------------------------------------------------------

  Future<void> getCurrentLocation() async {
    if (!mounted) return;

    setState(() {
      isGettingLocation = true;
    });

    try {
      bool serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception(
          'Location services are disabled. Please enable GPS.',
        );
      }

      LocationPermission permission =
      await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
        await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Exception(
          'Location permission denied.',
        );
      }

      if (permission ==
          LocationPermission.deniedForever) {
        throw Exception(
          'Location permission permanently denied. '
              'Please enable it from phone settings.',
        );
      }

      final position =
      await Geolocator.getCurrentPosition(
        locationSettings:
        const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });

      debugPrint(
        'Location: ${position.latitude}, ${position.longitude}',
      );
    } catch (e) {
      debugPrint(
        'Location error: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to get location: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isGettingLocation = false;
        });
      }
    }
  }
  Future<void> sendEmergencySMS() async {
    if (selectedContactIds.isEmpty) {
      debugPrint('No emergency contacts selected.');
      return;
    }

    try {
      // Get all emergency contacts from Django
      final contacts =
      await EmergencyContactService.instance.getContacts();

      // Only keep contacts selected by the user
      final selectedContacts = contacts.where((contact) {
        final id = int.tryParse(contact['id'].toString());
        return id != null && selectedContactIds.contains(id);
      }).toList();

      debugPrint(
        'Selected contacts for SMS: ${selectedContacts.length}',
      );

      if (selectedContacts.isEmpty) {
        debugPrint('No matching selected contacts found.');
        return;
      }

      final emergencyMessage = '''
🚨 CONNECTSAFE EMERGENCY 🚨

Emergency Type: ${widget.emergencyType}
Priority: $selectedPriority

${messageController.text.trim()}

📍 My current location:
https://maps.google.com/?q=$latitude,$longitude

Please provide immediate assistance.
''';

      int successCount = 0;

      for (final contact in selectedContacts) {
        final phone = contact['phone']?.toString();

        if (phone == null || phone.isEmpty) {
          debugPrint(
            'Skipping contact ${contact['id']} - phone number missing',
          );
          continue;
        }

        debugPrint(
          'Sending emergency SMS to ${contact['name']} - $phone',
        );

        final success = await SmsService.instance.sendSMS(
          phone: phone,
          message: emergencyMessage,
        );

        if (success) {
          successCount++;
        }
      }

      debugPrint(
        'Emergency SMS completed: '
            '$successCount/${selectedContacts.length}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Emergency SMS sent to '
                  '$successCount/${selectedContacts.length} selected contact(s).',
            ),
            backgroundColor:
            successCount == selectedContacts.length
                ? Colors.green
                : Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint('Emergency SMS error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SMS sending failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ----------------------------------------------------------
  // SEND EMERGENCY
  // ----------------------------------------------------------

  Future<void> sendEmergency() async {
    FocusScope.of(context).unfocus();

    if (messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter an emergency message.',
          ),
        ),
      );
      return;
    }

    // Try to get location if not available.
    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Getting your location...',
          ),
        ),
      );

      await getCurrentLocation();

      if (latitude == null || longitude == null) {
        return;
      }
    }

    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final result =
      await EmergencyMessageService.instance
          .createMessage(
        message: messageController.text.trim(),
        latitude: latitude!,
        longitude: longitude!,
        priority: selectedPriority,
        emergencyType: widget.emergencyType,
        contactIds: selectedContactIds,
      );

      debugPrint(
        'Emergency created successfully: $result',
      );
      await sendEmergencySMS();

      if (!mounted) return;

      final typeText =
      widget.emergencyType == 'FLOOD'
          ? 'Flood rescue request sent successfully.'
          : 'Emergency message sent successfully.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(typeText),
          backgroundColor: Colors.green,
        ),
      );

      messageController.clear();
    } catch (e) {
      debugPrint(
        'Emergency creation failed: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to send emergency: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }



  // ----------------------------------------------------------
  // BUILD UI
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final bool isFlood = widget.emergencyType == 'FLOOD';

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: Text(widget.incidentTitle),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // ------------------------------------------------
            // EMERGENCY TYPE
            // ------------------------------------------------

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: isFlood
                    ? Colors.blue.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),

                borderRadius:
                BorderRadius.circular(16),

                border: Border.all(
                  color: isFlood
                      ? Colors.blue
                      : Colors.red,
                ),
              ),

              child: Row(
                children: [
                  Icon(
                    isFlood
                        ? Icons.water
                        : Icons.warning_rounded,

                    color: isFlood
                        ? Colors.blue
                        : Colors.red,

                    size: 32,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [
                        Text(
                          isFlood
                              ? 'FLOOD RESCUE'
                              : 'EMERGENCY',

                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                            FontWeight.bold,

                            color: isFlood
                                ? Colors.blue
                                : Colors.red,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          isFlood
                              ? 'Your request will be sent to the rescue team.'
                              : 'Your emergency contacts will be notified.',

                          style: const TextStyle(
                            color:
                            AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ------------------------------------------------
            // MESSAGE
            // ------------------------------------------------

            TextField(
              controller: messageController,

              maxLines: 5,

              decoration: const InputDecoration(
                labelText: 'Emergency Message',

                hintText:
                'Describe your emergency...',

                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // ------------------------------------------------
            // PRIORITY
            // ------------------------------------------------

            DropdownButtonFormField<String>(
              value: selectedPriority,

              decoration:
              const InputDecoration(
                labelText: 'Priority',
                border:
                OutlineInputBorder(),
              ),

              items: const [
                DropdownMenuItem(
                  value: 'HIGH',
                  child: Text('High'),
                ),

                DropdownMenuItem(
                  value: 'MEDIUM',
                  child: Text('Medium'),
                ),

                DropdownMenuItem(
                  value: 'LOW',
                  child: Text('Low'),
                ),
              ],

              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedPriority = value;
                  });
                }
              },
            ),

            const SizedBox(height: 25),


            const SizedBox(height: 25),

        const SizedBox(height: 25),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Emergency Contacts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                selectedContactIds.isEmpty
                    ? 'No emergency contacts added.\nYou can continue without personal contacts.'
                    : '${selectedContactIds.length} contact(s) selected',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: selectEmergencyContacts,
                  icon: const Icon(Icons.people_outline),
                  label: Text(
                    selectedContactIds.isEmpty
                        ? 'Select Emergency Contacts'
                        : 'Change Contacts',
                  ),
                ),
              ),
            ],
          ),
        ),


            // ------------------------------------------------
            // LOCATION
            // ------------------------------------------------

            if (isGettingLocation)
              const Row(
                mainAxisAlignment:
                MainAxisAlignment.center,

                children: [
                  SizedBox(
                    width: 20,
                    height: 20,

                    child:
                    CircularProgressIndicator(),
                  ),

                  SizedBox(width: 10),

                  Text(
                    'Detecting location...',
                  ),
                ],
              )
            else if (
            latitude != null &&
                longitude != null
            )
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.all(15),

                decoration: BoxDecoration(
                  color: Colors.green
                      .withOpacity(0.1),

                  borderRadius:
                  BorderRadius.circular(12),
                ),

                child: Column(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.green,
                      size: 30,
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'Location detected',
                      style: TextStyle(
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Latitude: '
                          '${latitude!.toStringAsFixed(6)}\n'
                          'Longitude: '
                          '${longitude!.toStringAsFixed(6)}',

                      textAlign:
                      TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              const Text(
                'Location unavailable',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),

            const SizedBox(height: 30),

            // ------------------------------------------------
            // SEND BUTTON
            // ------------------------------------------------

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed:
                isLoading
                    ? null
                    : sendEmergency,

                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  isFlood
                      ? Colors.blue
                      : Colors.red,

                  foregroundColor:
                  Colors.white,

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(15),
                  ),
                ),

                child: isLoading
                    ? const SizedBox(
                  width: 25,
                  height: 25,

                  child:
                  CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
                    : Text(
                  isFlood
                      ? 'REQUEST FLOOD RESCUE'
                      : 'SEND EMERGENCY',

                  style:
                  const TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }
}