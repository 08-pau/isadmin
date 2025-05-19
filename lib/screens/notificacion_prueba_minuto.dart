import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificacionPruebaMinutoScreen extends StatefulWidget {
  const NotificacionPruebaMinutoScreen({super.key});

  @override
  State<NotificacionPruebaMinutoScreen> createState() => _NotificacionPruebaMinutoScreenState();
}

class _NotificacionPruebaMinutoScreenState extends State<NotificacionPruebaMinutoScreen> {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _flutterLocalNotificationsPlugin.initialize(settings);

    const androidChannel = AndroidNotificationChannel(
      'prueba_channel',
      'Canal de Prueba',
      description: 'Canal para pruebas de notificación',
      importance: Importance.high,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> _programarNotificacionEnUnMinuto() async {
    final ahora = DateTime.now().add(const Duration(minutes: 1));
    final tzDateTime = tz.TZDateTime.from(ahora, tz.local);
    final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    const androidDetails = AndroidNotificationDetails(
      'prueba_channel',
      'Canal de Prueba',
      channelDescription: 'Canal para pruebas de notificación',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    final details = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      '✅ Notificación Programada',
      'Esta notificación llegó 1 minuto después de programarla.',
      tzDateTime,
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Notificación programada para dentro de 1 minuto")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prueba Notificación 1 Minuto')),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.notifications),
          label: const Text("Probar Notificación"),
          onPressed: _programarNotificacionEnUnMinuto,
        ),
      ),
    );
  }
}