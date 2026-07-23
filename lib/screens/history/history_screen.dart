import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  static const List<Map<String, String>> history = [
    {
      "title": "SOS Activated",
      "subtitle": "21 Jul 2026 • 10:32 PM",
      "icon": "sos",
    },
    {
      "title": "Safe Route Checked",
      "subtitle": "20 Jul 2026 • 6:15 PM",
      "icon": "route",
    },
    {
      "title": "Nearby Help Search",
      "subtitle": "19 Jul 2026 • 8:05 PM",
      "icon": "location",
    },
    {
      "title": "Emergency Contact Added",
      "subtitle": "18 Jul 2026 • 4:20 PM",
      "icon": "contact",
    },
  ];

  static IconData _getIcon(String? type) {
    switch (type) {
      case "sos":
        return Icons.warning_rounded;
      case "route":
        return Icons.route;
      case "location":
        return Icons.location_on;
      case "contact":
        return Icons.contacts;
      default:
        return Icons.history;
    }
  }

  static Color _getIconColor(String? type) {
    switch (type) {
      case "sos":
        return AppColors.sos;
      default:
        return AppColors.primary;
    }
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
          "History",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: history.isEmpty
          ? const Center(
        child: Text(
          "No History Available",
          style: TextStyle(
            fontSize: 18,
            color: AppColors.textSecondary,
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 0,
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(
                color: AppColors.border,
              ),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                _getIconColor(item["icon"]).withOpacity(0.12),
                child: Icon(
                  _getIcon(item["icon"]),
                  color: _getIconColor(item["icon"]),
                ),
              ),
              title: Text(
                item["title"]!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Text(item["subtitle"]!),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }
}