import 'package:flutter/material.dart';
import '../../constants.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'type': 'like',
      'user': 'Marie Dupont',
      'message': 'a aimé votre publication',
      'time': 'Il y a 5 min',
      'read': false,
      'avatar': null,
    },
    {
      'id': '2',
      'type': 'comment',
      'user': 'Jean Martin',
      'message': 'a commenté votre publication',
      'time': 'Il y a 15 min',
      'read': false,
      'avatar': null,
    },
    {
      'id': '3',
      'type': 'mention',
      'user': 'Sophie Bernard',
      'message': 'vous a mentionné dans un commentaire',
      'time': 'Il y a 1h',
      'read': true,
      'avatar': null,
    },
    {
      'id': '4',
      'type': 'group',
      'user': 'Système',
      'message': 'Vous avez été ajouté au groupe "Innovation"',
      'time': 'Il y a 2h',
      'read': true,
      'avatar': null,
    },
    {
      'id': '5',
      'type': 'message',
      'user': 'Lucas Petit',
      'message': 'vous a envoyé un message',
      'time': 'Hier',
      'read': true,
      'avatar': null,
    },
  ];

  IconData _getIcon(String type) {
    switch (type) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.chat_bubble;
      case 'mention':
        return Icons.alternate_email;
      case 'group':
        return Icons.group_add;
      case 'message':
        return Icons.message;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'like':
        return AppColors.error;
      case 'comment':
        return AppColors.primary;
      case 'mention':
        return AppColors.accent;
      case 'group':
        return AppColors.success;
      case 'message':
        return AppColors.primaryLight;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n['read']).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () {
                setState(() {
                  for (var n in _notifications) {
                    n['read'] = true;
                  }
                });
              },
              child: const Text(
                'Tout marquer comme lu',
                style: TextStyle(color: AppColors.white),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: AppColors.textHint,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aucune notification',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notif = _notifications[index];
                return Dismissible(
                  key: Key(notif['id']),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: AppColors.error,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: AppColors.white),
                  ),
                  onDismissed: (_) {
                    setState(() {
                      _notifications.removeAt(index);
                    });
                  },
                  child: Container(
                    color: notif['read']
                        ? AppColors.white
                        : AppColors.primary.withOpacity(0.05),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: _getIconColor(notif['type'])
                                .withOpacity(0.1),
                            child: Text(
                              notif['user'][0].toUpperCase(),
                              style: TextStyle(
                                color: _getIconColor(notif['type']),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: _getIconColor(notif['type']),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.white,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                _getIcon(notif['type']),
                                size: 10,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      title: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: notif['user'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: ' ${notif['message']}'),
                          ],
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          notif['time'],
                          style: AppTextStyles.caption,
                        ),
                      ),
                      trailing: notif['read']
                          ? null
                          : Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                      onTap: () {
                        setState(() {
                          notif['read'] = true;
                        });
                        // Navigation vers le détail
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}