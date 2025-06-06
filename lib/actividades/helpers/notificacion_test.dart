import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  await _inicializarNotificaciones();

  runApp(const MaterialApp(
    home: NotificacionTestScreen(),
  ));
}

Future<bool> _inicializarNotificaciones() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  if (Platform.isAndroid) {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      final result = await Permission.notification.request();
      if (!result.isGranted) return false;
    }
  }

  return true;
}

class NotificacionTestScreen extends StatelessWidget {
  const NotificacionTestScreen({super.key});

  void _mostrarNotificacion() async {
    final ahora = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 3));

    await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      '🔔 Prueba Inmediata',
      '¡Hola! Esto es una notificación de prueba.',
      ahora,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'canal_test',
          'Canal de prueba',
          channelDescription: 'Prueba básica de notificaciones',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Prueba de Notificación")),
      body: Center(
        child: ElevatedButton(
          onPressed: _mostrarNotificacion,
          child: const Text("Enviar notificación en 3 segundos"),
        ),
      ),
    );
  }
}
