import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/theme/light_theme.dart';
import '../providers/notification_provider.dart';
import '../../auth/providers/auth_provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final idUser = context.read<AuthProvider>().currentUser?.idUser ?? '';
      if (idUser.isNotEmpty) {
        context.read<NotificationProvider>().fetchNotifications(idUser);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightTheme.background,
      appBar: AppBar(
        title: const Text('Notifikasi', style: TextStyle(color: LightTheme.textPrimary, fontWeight: FontWeight.w700)),
        backgroundColor: LightTheme.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: LightTheme.textPrimary),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: LightTheme.primary));
          }

          if (provider.notifications.isEmpty) {
            return const Center(
              child: Text('Belum ada notifikasi', style: TextStyle(color: LightTheme.textSecondary)),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: provider.notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notif = provider.notifications[index];
              final isRead = notif['is_read'] == 1 || notif['is_read'] == '1';

              return GestureDetector(
                onTap: () {
                  if (!isRead) {
                    provider.markAsRead(notif['id_notif'].toString());
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isRead ? Colors.white : LightTheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isRead ? LightTheme.border : LightTheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isRead ? LightTheme.surface : LightTheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_active_rounded,
                          color: isRead ? LightTheme.textTertiary : LightTheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notif['judul'] ?? 'Notifikasi',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                                color: LightTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notif['pesan'] ?? '',
                              style: const TextStyle(fontSize: 12, color: LightTheme.textSecondary),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              notif['created_at'] ?? '',
                              style: const TextStyle(fontSize: 10, color: LightTheme.textTertiary),
                            ),
                          ],
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 8),
                          decoration: const BoxDecoration(
                            color: LightTheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
