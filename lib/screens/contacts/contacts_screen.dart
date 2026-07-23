import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
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
  final List<Map<String, String>> contacts = [
    {
      "name": "John Doe",
      "phone": "+91 9876543210",
    },
    {
      "name": "Jane Smith",
      "phone": "+91 9123456780",
    },
  ];

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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddContactScreen(),
            ),
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),

      body: contacts.isEmpty
          ? const EmptyContacts()
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];

          return ContactCard(
            name: contact["name"]!,
            phone: contact["phone"]!,
            onEdit: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditContactScreen(
                    name: contact["name"]!,
                    phone: contact["phone"]!,
                  ),
                ),
              );
            },
            onDelete: () {
              setState(() {
                contacts.removeAt(index);
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Contact deleted"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}