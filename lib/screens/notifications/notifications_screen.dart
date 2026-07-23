import 'package:flutter/material.dart';

import '../../core/widgets/custom_scaffold.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<_NotificationItem> _notifications = [
    _NotificationItem(
      icon: Icons.warning_amber_rounded,
      color: Colors.red,
      title: "SOS Alert Sent",
      message: "Your emergency contacts have been notified successfully.",
      time: "2 min ago",
      unread: true,
    ),
    _NotificationItem(
      icon: Icons.location_on,
      color: Colors.blue,
      title: "Safe Route Available",
      message: "A safer route with better lighting has been found.",
      time: "12 min ago",
      unread: true,
    ),
    _NotificationItem(
      icon: Icons.smart_toy,
      color: Colors.green,
      title: "AI Assistant",
      message: "Your safety guidance conversation is available.",
      time: "Yesterday",
    ),
    _NotificationItem(
      icon: Icons.local_hospital,
      color: Colors.orange,
      title: "Nearby Hospital",
      message: "Hospital services are available near your location.",
      time: "Yesterday",
    ),
    _NotificationItem(
      icon: Icons.people,
      color: Colors.deepPurple,
      title: "Emergency Contact Updated",
      message: "Primary emergency contact was successfully updated.",
      time: "2 days ago",
    ),
  ];

  void _markAllRead() {
    setState(() {
      for (final notification in _notifications) {
        notification.unread = false;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("All notifications marked as read."),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteNotification(int index) {
    final title = _notifications[index].title;

    setState(() {
      _notifications.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$title removed"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: "Notifications",
      body: _notifications.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.notifications_off_outlined,
              size: 70,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              "No notifications",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "You're all caught up!",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _notifications.length + 1,
        itemBuilder: (context, index) {
          if (index == _notifications.length) {
            return Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 30),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: _markAllRead,
                  icon: const Icon(Icons.done_all),
                  label: const Text("Mark All as Read"),
                ),
              ),
            );
          }

          final notification = _notifications[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Card(
              elevation: notification.unread ? 3 : 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  setState(() {
                    notification.unread = false;
                  });
                },
                onLongPress: () => _deleteNotification(index),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor:
                            notification.color.withOpacity(.15),
                            child: Icon(
                              notification.icon,
                              color: notification.color,
                            ),
                          ),
                          if (notification.unread)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight: notification.unread
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(notification.message),
                            const SizedBox(height: 8),
                            Text(
                              notification.time,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationItem {
  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final String time;
  bool unread;

  _NotificationItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    required this.time,
    this.unread = false,
  });
}