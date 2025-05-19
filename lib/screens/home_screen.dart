import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'StudentDrawer.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HomeScreen({super.key, required this.userData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<QueryDocumentSnapshot> _tareasDelDia = [];

  final Color fondoSuave = const Color(0xFFEDE7F6); // Morado claro suave

  @override
  void initState() {
    super.initState();
    _fetchTareasDelDia(_selectedDay);
  }

  void _fetchTareasDelDia(DateTime fecha) async {
    DateTime startOfDay = DateTime(fecha.year, fecha.month, fecha.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await FirebaseFirestore.instance
        .collection('tareas')
        .where('fechaInicio', isGreaterThanOrEqualTo: startOfDay)
        .where('fechaInicio', isLessThan: endOfDay)
        .orderBy('fechaInicio')
        .get();

    setState(() {
      _tareasDelDia = snapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondoSuave,
      drawer: StudentDrawer(userData: widget.userData),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7C3AED),
        elevation: 0,
        title: const Text("Administrador Estudiantil", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Calendario con fondo suave
              Container(
                decoration: BoxDecoration(
                  color: fondoSuave,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(12),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _fetchTareasDelDia(selectedDay);
                  },
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                    leftChevronIcon: Icon(Icons.chevron_left, color: Colors.deepPurple),
                    rightChevronIcon: Icon(Icons.chevron_right, color: Colors.deepPurple),
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.deepPurpleAccent,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.deepPurple,
                      shape: BoxShape.circle,
                    ),
                    weekendTextStyle: const TextStyle(color: Colors.redAccent),
                    defaultTextStyle: const TextStyle(color: Colors.black87, fontSize: 16),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekendStyle: TextStyle(color: Colors.redAccent),
                    weekdayStyle: TextStyle(color: Colors.deepPurple),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                "Tareas del día",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: _tareasDelDia.isEmpty
                    ? const Center(
                        child: Text(
                          "No hay tareas para esta fecha",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _tareasDelDia.length,
                        itemBuilder: (context, index) {
                          final tarea = _tareasDelDia[index].data() as Map<String, dynamic>;
                          return _buildTodayTask(
                            tarea['nombre'] ?? 'Sin título',
                            tarea['detalle'] ?? 'Sin detalle',
                            [tarea['estado'] ?? 'Sin estado'],
                          );
                        },
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayTask(String title, String subtitle, List<String> tags) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF7C3AED), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.task_alt, color: Color(0xFF7C3AED)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              children: tags
                  .map((tag) => Chip(
                        label: Text(tag),
                        backgroundColor: Colors.grey.shade200,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

