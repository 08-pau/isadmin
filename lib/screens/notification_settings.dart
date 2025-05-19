import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  DateTime _selectedDateTime = DateTime.now().add(const Duration(hours: 1));
  String _repeat = 'Una vez';
  String _selectedSound = 'alarma1.wav'; // Debes agregar estos sonidos en android/app/src/main/res/raw/
  int _remindBeforeMinutes = 10;

  final List<String> _repeatOptions = ['Una vez', 'Diariamente', 'Semanalmente'];
  final List<String> _soundOptions = ['alarma1.wav', 'alarma2.wav', 'alarma3.wav'];

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // icono personalizado
    const InitializationSettings settings = InitializationSettings(android: androidSettings);

    await _flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        // Redirecciona a una pantalla específica
        Navigator.pushNamed(context, "/taskDetail");
      },
    );
  }

  Future<void> _scheduleNotification() async {
    final scheduledTime = _selectedDateTime.subtract(Duration(minutes: _remindBeforeMinutes));

    final androidDetails = AndroidNotificationDetails(
      'tareas_channel',
      'Recordatorios de tareas',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(_selectedSound.split('.').first),
      icon: '@mipmap/ic_launcher',
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    if (_repeat == "Una vez") {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Tarea programada',
        'Tienes una tarea pendiente',
        tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } else {
      final interval = _repeat == "Diariamente"
          ? RepeatInterval.daily
          : RepeatInterval.weekly;

      await _flutterLocalNotificationsPlugin.periodicallyShow(
        0,
        'Tarea Recurrente',
        'Tienes una tarea que se repite $_repeat',
        interval,
        notificationDetails,
        androidAllowWhileIdle: true,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Notificación programada con éxito.")),
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Configuración de Notificaciones")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text("📅 Selecciona fecha y hora"),
            ListTile(
              title: Text(_selectedDateTime.toString()),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDateTime,
            ),
            const SizedBox(height: 16),

            const Text("🔁 Repetición"),
            DropdownButton<String>(
              value: _repeat,
              onChanged: (value) => setState(() => _repeat = value!),
              items: _repeatOptions
                  .map((option) => DropdownMenuItem(value: option, child: Text(option)))
                  .toList(),
            ),
            const SizedBox(height: 16),

            const Text("🔊 Sonido de notificación"),
            DropdownButton<String>(
              value: _selectedSound,
              onChanged: (value) => setState(() => _selectedSound = value!),
              items: _soundOptions
                  .map((sound) => DropdownMenuItem(value: sound, child: Text(sound)))
                  .toList(),
            ),
            const SizedBox(height: 16),

            const Text("⏰ ¿Cuánto antes notificar? (minutos)"),
            Slider(
              value: _remindBeforeMinutes.toDouble(),
              min: 1,
              max: 60,
              divisions: 59,
              label: "$_remindBeforeMinutes minutos",
              onChanged: (value) => setState(() => _remindBeforeMinutes = value.toInt()),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _scheduleNotification,
              child: const Text("Programar Notificación"),
            ),
          ],
        ),
      ),
    );
  }
}
