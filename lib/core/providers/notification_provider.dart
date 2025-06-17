import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:bs_vistoria_veicular/core/services/notification_service.dart';

final flutterLocalNotificationsPluginProvider =
    Provider<FlutterLocalNotificationsPlugin>((ref) {
  throw UnimplementedError('Este provedor deve ser sobrescrito em main.dart');
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      ref.watch(flutterLocalNotificationsPluginProvider);
  return NotificationService(notificationsPlugin);
});
