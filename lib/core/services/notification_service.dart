import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:bs_vistoria_veicular/features/contas_receber/domain/entities/conta_receber.dart';
import 'package:bs_vistoria_veicular/features/contas_pagar/domain/entities/conta_pagar.dart';
import 'package:intl/intl.dart' as intl;

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin;

  NotificationService(this.notificationsPlugin) {
    tz.initializeTimeZones();
    final String? timeZoneName = tz.local.name; // Use o fuso horário local
    tz.setLocalLocation(tz.getLocation(timeZoneName!));
  }

  Future<void> showScheduledNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'vencimentos_channel',
      'Vencimentos Futuros',
      channelDescription:
          'Notificações para contas a receber e a pagar que vencem em breve.',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }

  Future<void> scheduleFutureDueNotifications({
    required List<ContaReceber> contasAReceberProvisao,
    required List<ContaPagar> contasAPagarProvisao,
  }) async {
    await cancelAllNotifications(); // Limpa notificações anteriores para evitar duplicatas

    int notificationId = 0; // ID para garantir notificações únicas

    for (var conta in contasAReceberProvisao) {
      // Agendar notificação 1 dia antes do vencimento
      final DateTime notificationDate =
          conta.dataRecebimento.subtract(const Duration(days: 1));

      if (notificationDate.isAfter(DateTime.now())) {
        // Apenas se a data da notificação for futura
        await showScheduledNotification(
          id: notificationId,
          title: 'Vencimento de Conta a Receber',
          body:
              'A conta de ${conta.descricao} no valor de R\$ ${conta.valor.toStringAsFixed(2)} vence em ${intl.DateFormat('dd/MM/yyyy').format(conta.dataRecebimento)}.',
          scheduledDate: notificationDate,
        );
        notificationId++;
      }
    }

    for (var conta in contasAPagarProvisao) {
      // Agendar notificação 1 dia antes do vencimento
      final DateTime notificationDate =
          conta.dataPagamento.subtract(const Duration(days: 1));

      if (notificationDate.isAfter(DateTime.now())) {
        // Apenas se a data da notificação for futura
        await showScheduledNotification(
          id: notificationId,
          title: 'Vencimento de Conta a Pagar',
          body:
              'A conta de ${conta.descricao} no valor de R\$ ${conta.valor.toStringAsFixed(2)} vence em ${intl.DateFormat('dd/MM/yyyy').format(conta.dataPagamento)}.',
          scheduledDate: notificationDate,
        );
        notificationId++;
      }
    }
  }
}
