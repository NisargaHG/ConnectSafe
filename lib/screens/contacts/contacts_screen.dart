import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/emergency_contact_service.dart';
import 'add_contact_screen.dart';
import 'edit_contact_screen.dart';
import 'widgets/contact_card.dart';
import 'widgets/empty_contacts.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<dynamic> contacts = [];

  bool isLoading = true;

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
      debugPrint('CONTACT LOAD FAILED: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load contacts: $e'),
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
        centerTitle: true,
        title: const Text(
          "Emergency Contacts",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddContactScreen(),
            ),
          );

          if (result == true) {
            loadContacts();
          }
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),

      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : contacts.isEmpty
          ? const EmptyContacts()
          : RefreshIndicator(
        onRefresh: loadContacts,
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final contact = contacts[index];

            return ContactCard(
              id: int.parse(contact['id'].toString()),
              name: contact['name']?.toString() ?? '',
              phone: contact['phone']?.toString() ?? '',
              onEdit: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditContactScreen(
                      id: int.parse(contact['id'].toString()),
                      name: contact['name']?.toString() ?? '',
                      phone: contact['phone']?.toString() ?? '',
                    ),
                  ),
                );

                if (result == true) {
                  loadContacts();
                }
              },
              onDelete: () async {
                try {
                  await EmergencyContactService.instance.deleteContact(
                    int.parse(contact['id'].toString()),
                  );

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Contact deleted successfully"),
                      backgroundColor: Colors.green,
                    ),
                  );

                  loadContacts();
                } catch (e) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Failed to delete contact: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}