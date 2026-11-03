import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'emergency_message_screen.dart';

class IncidentSelectionScreen extends StatelessWidget {
  const IncidentSelectionScreen({super.key});

  static const List<Map<String, dynamic>> incidents = [
    {
      'type': 'GENERAL',
      'title': 'General Emergency',
      'icon': Icons.warning_rounded,
    },
    {
      'type': 'FLOOD',
      'title': 'Flood',
      'icon': Icons.water,
    },
    {
      'type': 'EARTHQUAKE',
      'title': 'Earthquake',
      'icon': Icons.public,
    },
    {
      'type': 'FIRE',
      'title': 'Fire',
      'icon': Icons.local_fire_department,
    },
    {
      'type': 'CYCLONE',
      'title': 'Cyclone',
      'icon': Icons.air,
    },
    {
      'type': 'THUNDERSTORM',
      'title': 'Thunderstorm',
      'icon': Icons.thunderstorm,
    },
    {
      'type': 'LANDSLIDE',
      'title': 'Landslide',
      'icon': Icons.terrain,
    },
    {
      'type': 'TSUNAMI',
      'title': 'Tsunami',
      'icon': Icons.waves,
    },
    {
      'type': 'HEAVY_RAIN',
      'title': 'Heavy Rain',
      'icon': Icons.cloudy_snowing,
    },
    {
      'type': 'HEATWAVE',
      'title': 'Heatwave',
      'icon': Icons.wb_sunny,
    },
    {
      'type': 'LIGHTNING',
      'title': 'Lightning',
      'icon': Icons.flash_on,
    },
    {
      'type': 'INDUSTRIAL',
      'title': 'Industrial Accident',
      'icon': Icons.factory,
    },
    {
      'type': 'CHEMICAL_LEAK',
      'title': 'Chemical Leak',
      'icon': Icons.science,
    },
    {
      'type': 'ROAD_ACCIDENT',
      'title': 'Road Accident',
      'icon': Icons.car_crash,
    },
    {
      'type': 'MEDICAL',
      'title': 'Medical Emergency',
      'icon': Icons.medical_services,
    },
    {
      'type': 'MISSING_PERSON',
      'title': 'Missing Person',
      'icon': Icons.person_search,
    },
    {
      'type': 'PERSONAL_SAFETY',
      'title': 'Personal Safety',
      'icon': Icons.shield,
    },
  ];

  void openEmergency(
      BuildContext context,
      String emergencyType,
      String title,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmergencyMessageScreen(
          emergencyType: emergencyType,
          incidentTitle: title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Select Emergency',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: incidents.length,
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (context, index) {
          final incident = incidents[index];

          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              openEmergency(
                context,
                incident['type'] as String,
                incident['title'] as String,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    incident['icon'] as IconData,
                    size: 42,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      incident['title'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}