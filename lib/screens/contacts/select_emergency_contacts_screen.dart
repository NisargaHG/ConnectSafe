import 'package:flutter/material.dart';

import '../../services/emergency_contact_service.dart';
import '../../core/constants/app_colors.dart';

class SelectEmergencyContactsScreen extends StatefulWidget {
  const SelectEmergencyContactsScreen({
    super.key,
  });

  @override
  State<SelectEmergencyContactsScreen> createState() =>
      _SelectEmergencyContactsScreenState();
}

class _SelectEmergencyContactsScreenState
    extends State<SelectEmergencyContactsScreen> {


  List<dynamic> contacts = [];
  final Set<int> selectedContactIds = {};

  bool isLoading = true;
  bool isContinuing = false;

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> loadContacts() async {
    try {
      final result =
      await EmergencyContactService.instance.getContacts();

      if (!mounted) return;

      setState(() {
        contacts = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load contacts: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Select Emergency Contacts',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : contacts.isEmpty
          ? const Center(
        child: Text(
          'No emergency contacts added.\nPlease add contacts first.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];

          final int id =
          int.parse(contact['id'].toString());

          final String name =
              contact['name']?.toString() ?? '';

          final String phone =
              contact['phone']?.toString() ?? '';

          final bool selected =
          selectedContactIds.contains(id);

          return Card(
            margin: const EdgeInsets.only(
              bottom: 10,
            ),
            child: CheckboxListTile(
              value: selected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    selectedContactIds.add(id);
                  } else {
                    selectedContactIds.remove(id);
                  }
                });
              },
              title: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(phone),
              secondary: const Icon(
                Icons.person,
              ),
            ),
          );
        },
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: isContinuing
                ? null
                : () {
              setState(() {
                isContinuing = true;
              });

              final selectedIds = selectedContactIds.toList();

              Navigator.pop(context, selectedIds);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                vertical: 16,
              ),
            ),
            child: isContinuing
                ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Text(
              'CONTINUE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}