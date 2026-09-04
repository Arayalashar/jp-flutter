import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/config/api_config.dart';

class NotificationProvider extends ChangeNotifier {
  List<dynamic> _notifications = [];
  bool _isLoading = false;

  List<dynamic> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => n['is_read'] == 0 || n['is_read'] == '0').length;

  Future<void> fetchNotifications(String idUser) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.get('${ApiConfig.getNotifikasi}?id_user=$idUser');
      if (response['status'] == 'success') {
        _notifications = response['data'] ?? [];
      }
    } catch (e) {
      debugPrint('Error fetch notifications: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(String idNotif) async {
    // Optimistic UI update
    final index = _notifications.indexWhere((n) => n['id_notif'].toString() == idNotif.toString());
    if (index != -1) {
      _notifications[index]['is_read'] = 1;
      notifyListeners();
    }

    try {
      await ApiClient.post(
        ApiConfig.readNotifikasi,
        body: {'id_notif': idNotif},
      );
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      // Revert if failed
      if (index != -1) {
        _notifications[index]['is_read'] = 0;
        notifyListeners();
      }
    }
  }
}
