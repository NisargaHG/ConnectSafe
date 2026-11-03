import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ContactCard extends StatelessWidget {
  final int id;
  final String name;
  final String phone;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ContactCard({
    super.key,
    required this.id,
    required this.name,
    required this.phone,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: AppColors.border,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: const Icon(
            Icons.person,
            color: AppColors.primary,
            size: 28,
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            phone,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: "Call",
              icon: const Icon(
                Icons.call,
                color: Colors.green,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Calling feature coming soon.",
                    ),
                  ),
                );
              },
            ),
            IconButton(
              tooltip: "Message",
              icon: const Icon(
                Icons.message,
                color: AppColors.accent,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Messaging feature coming soon.",
                    ),
                  ),
                );
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit?.call();
                    break;

                  case 'delete':
                    onDelete?.call();
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}