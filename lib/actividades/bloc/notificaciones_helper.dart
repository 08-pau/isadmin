import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<bool> inicializarNotificaciones() async {
  const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings = InitializationSettings(android: androidInit);
  await flutterLocalNotificationsPlugin.initialize(initSettings);
  tz.initializeTimeZones();

  const AndroidNotificationChannel canal = AndroidNotificationChannel(
    'actividades_id',
    'Recordatorios',
    description: 'Notificaciones de actividades programadas',
    importance: Importance.max,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(canal);

  if (Platform.isAndroid) {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      final result = await Permission.notification.request();
      if (!result.isGranted) return false;
    }
  }

  return true;
}

Future<void> programarNotificacion({
  required String titulo,
  required String descripcion,
  required DateTime fecha,
  required TimeOfDay hora,
}) async {
  final tiempo = tz.TZDateTime.local(
    fecha.year,
    fecha.month,
    fecha.day,
    hora.hour,
    hora.minute,
  );

  print("⏰ Programando notificación para: \$tiempo");

  await flutterLocalNotificationsPlugin.zonedSchedule(
    tiempo.hashCode,
    '📌 \$titulo',
    descripcion,
    tiempo,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'actividades_id',
        'Recordatorios',
        channelDescription: 'Notificaciones de actividades programadas',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    ),
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.dateAndTime,
  );
}

Future<void> programarNotificacionInmediata(String titulo, String descripcion) async {
  final ahora = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
  print("⏰ Programando notificación inmediata para: \$ahora");

  await flutterLocalNotificationsPlugin.zonedSchedule(
    ahora.hashCode,
    '📌 \$titulo',
    descripcion,
    ahora,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'actividades_id',
        'Recordatorios',
        channelDescription: 'Notificaciones de actividades programadas',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    ),
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.dateAndTime,
  );
}
