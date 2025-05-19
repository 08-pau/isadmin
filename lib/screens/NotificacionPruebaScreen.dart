import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificacionPruebaScreen extends StatefulWidget {
  const NotificacionPruebaScreen({super.key});

  @override
  State<NotificacionPruebaScreen> createState() => _NotificacionPruebaScreenState();
}

class _NotificacionPruebaScreenState extends State<NotificacionPruebaScreen> {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initNotifications();

    // 🔔 Dispara una notificación inmediata
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _flutterLocalNotificationsPlugin.show(
        999,
        '🔔 Notificación de prueba',
        'Esto es una prueba local inmediata',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'actividades_channel',
            'Recordatorios de Actividades',
            channelDescription: 'Canal de prueba de notificaciones',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    });
  }

  Future<void> _initNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _flutterLocalNotificationsPlugin.initialize(settings);

    const androidChannel = AndroidNotificationChannel(
      'actividades_channel',
      'Recordatorios de Actividades',
      description: 'Canal de prueba de notificaciones',
      importance: Importance.high,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prueba de Notificación')),
      body: const Center(
        child: Text('Si ves una notificación, ¡todo funciona bien!'),
      ),
    );
  }
}