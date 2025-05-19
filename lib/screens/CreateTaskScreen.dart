import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class CreateTaskScreen extends StatefulWidget {
  final String materiaId;

  const CreateTaskScreen({super.key, required this.materiaId});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _taskNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _urgencyCategory = "Normal";
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 11, minute: 0);
  bool _notify = false;

  DateTime _startRepeatDate = DateTime.now();
  DateTime _endRepeatDate = DateTime.now().add(const Duration(days: 1));
  List<TimeOfDay> _horasDelDia = [const TimeOfDay(hour: 8, minute: 0)];

  final List<String> _urgencyLevels = ["Baja", "Normal", "Urgente"];
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  List<int> _notificacionIds = [];

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _flutterLocalNotificationsPlugin.initialize(initSettings);

    const channel = AndroidNotificationChannel(
      'actividades_channel',
      'Recordatorios de Actividades',
      description: 'Notificaciones exactas por tarea',
      importance: Importance.high,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> _programarNotificaciones() async {
    int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    final start = _startRepeatDate;
    final end = _endRepeatDate;

    for (var day = start; !day.isAfter(end); day = day.add(const Duration(days: 1))) {
      for (final hora in _horasDelDia) {
        final scheduledDate = DateTime(day.year, day.month, day.day, hora.hour, hora.minute);

        DateTime adjusted = scheduledDate;
        if (adjusted.isBefore(DateTime.now().add(const Duration(minutes: 1)))) {
          adjusted = adjusted.add(const Duration(days: 1));
        }

        final tzDateTime = tz.TZDateTime.from(adjusted, tz.local);

        final androidDetails = AndroidNotificationDetails(
          'actividades_channel',
          'Recordatorios de Actividades',
          channelDescription: 'Notificaciones exactas por tarea',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(
            'Tarea: ${_taskNameController.text}\nDescripción: ${_descriptionController.text}',
            contentTitle: '📌 Recordatorio de Actividad',
          ),
        );

        await _flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          '🔔 Haz la tarea: ${_taskNameController.text}',
          'Descripción: ${_descriptionController.text}',
          tzDateTime,
          NotificationDetails(android: androidDetails),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );

        _notificacionIds.add(id);
        id++;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Se programaron ${_notificacionIds.length} notificaciones."),
    ));
  }

  Future<void> _cancelarNotificaciones() async {
    for (final id in _notificacionIds) {
      await _flutterLocalNotificationsPlugin.cancel(id);
    }
    setState(() {
      _notificacionIds.clear();
      _horasDelDia.clear();
    });
  }

  Future<void> _guardarActividad() async {
    await FirebaseFirestore.instance
        .collection('materias')
        .doc(widget.materiaId)
        .collection('actividades')
        .add({
      'titulo': _taskNameController.text,
      'descripcion': _descriptionController.text,
      'urgencia': _urgencyCategory,
      'fecha': Timestamp.fromDate(_selectedDate),
      'horaInicio': '${_startTime.hour}:${_startTime.minute}',
      'horaFin': '${_endTime.hour}:${_endTime.minute}',
      'notificar': _notify,
      'horasNotificacion': _horasDelDia
          .map((t) => '${t.hour}:${t.minute.toString().padLeft(2, '0')}')
          .toList(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (_notify) {
      await _programarNotificaciones();
    }

    Navigator.pop(context);
  }

  Future<void> _seleccionarHora() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) {
      setState(() => _horasDelDia.add(picked));
    }
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildTimeTile(String label, TimeOfDay time, VoidCallback onTap) {
    return Expanded(
      child: ListTile(
        title: Text(label),
        subtitle: Text(time.format(context)),
        trailing: const Icon(Icons.access_time),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F0FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7C3AED),
        elevation: 0,
        title: const Text("Crear Nueva Actividad", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Nombre de la Actividad"),
              TextField(
                controller: _taskNameController,
                decoration: const InputDecoration(
                  hintText: "Ej. Estudiar para examen",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              _buildLabel("Urgencia"),
              Wrap(
                spacing: 8,
                children: _urgencyLevels.map((level) {
                  return ChoiceChip(
                    label: Text(level),
                    selected: _urgencyCategory == level,
                    onSelected: (_) => setState(() => _urgencyCategory = level),
                    selectedColor: const Color(0xFF7C3AED),
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                      color: _urgencyCategory == level ? Colors.white : Colors.black,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              _buildLabel("Fecha"),
              ListTile(
                tileColor: Colors.grey[100],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                title: Text("${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}"),
                trailing: const Icon(Icons.calendar_today, color: Color(0xFF7C3AED)),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) setState(() => _selectedDate = date);
                },
              ),

              _buildLabel("Hora de inicio y fin"),
              Row(
                children: [
                  _buildTimeTile("Inicio", _startTime, () async {
                    final picked = await showTimePicker(context: context, initialTime: _startTime);
                    if (picked != null) setState(() => _startTime = picked);
                  }),
                  _buildTimeTile("Fin", _endTime, () async {
                    final picked = await showTimePicker(context: context, initialTime: _endTime);
                    if (picked != null) setState(() => _endTime = picked);
                  }),
                ],
              ),
              const SizedBox(height: 20),

              SwitchListTile(
                title: const Text("¿Notificarme?"),
                activeColor: const Color(0xFF7C3AED),
                value: _notify,
                onChanged: (val) => setState(() => _notify = val),
              ),

              if (_notify) ...[
                _buildLabel("Rango de notificación"),
                ListTile(
                  title: Text("Desde: ${_startRepeatDate.day}/${_startRepeatDate.month}/${_startRepeatDate.year}"),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startRepeatDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) setState(() => _startRepeatDate = date);
                  },
                ),
                ListTile(
                  title: Text("Hasta: ${_endRepeatDate.day}/${_endRepeatDate.month}/${_endRepeatDate.year}"),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _endRepeatDate,
                      firstDate: _startRepeatDate,
                      lastDate: DateTime(2100),
                    );
                    if (date != null) setState(() => _endRepeatDate = date);
                  },
                ),
                _buildLabel("Horas de notificación"),
                ..._horasDelDia.asMap().entries.map((entry) {
                  final i = entry.key;
                  final hora = entry.value;
                  return ListTile(
                    title: Text("⏰ ${hora.hour}:${hora.minute.toString().padLeft(2, '0')}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _horasDelDia.removeAt(i);
                        });
                      },
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: _seleccionarHora,
                  icon: const Icon(Icons.add_alarm),
                  label: const Text("Agregar hora"),
                ),
              ],

              const SizedBox(height: 16),
              _buildLabel("Descripción"),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "Escribe una descripción...",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),

              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text("Crear Actividad", style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _guardarActividad,
              ),
              if (_notify)
                TextButton(
                  onPressed: _cancelarNotificaciones,
                  child: const Text("Cancelar notificaciones programadas"),
                )
            ],
          ),
        ),
      ),
    );
  }
}
