import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../bloc/home_bloc.dart';
import 'package:isadmin/components/student_drawer.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HomeScreen({super.key, required this.userData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final Color fondoSuave = const Color(0xFFEDE7F6);

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(LoadTareasDelDia(fecha: _selectedDay));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondoSuave,
      drawer: StudentDrawer(userData: widget.userData),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7C3AED),
        elevation: 0,
        title: const Text("Administrador Estudiantil", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Calendario mejorado pero manteniendo tu estilo
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20), // Más redondeado
                  border: Border.all(color: const Color(0xFF7C3AED), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withOpacity(0.15),
                      blurRadius: 12, // Sombra más suave
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16), // Un poco más de padding
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
                    context.read<HomeBloc>().add(LoadTareasDelDia(fecha: selectedDay));
                  },
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      fontSize: 22, // Un poco más grande
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                    leftChevronIcon: Icon(Icons.chevron_left, color: Colors.deepPurple, size: 28),
                    rightChevronIcon: Icon(Icons.chevron_right, color: Colors.deepPurple, size: 28),
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.deepPurpleAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurpleAccent.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.deepPurple,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    weekendTextStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
                    defaultTextStyle: const TextStyle(color: Colors.black87, fontSize: 16),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekendStyle: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                    weekdayStyle: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Header de tareas mejorado
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.assignment,
                      color: Color(0xFF7C3AED),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Tareas del día",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF4A148C)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Expanded(
                child: BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    if (state is HomeLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
                        ),
                      );
                    } else if (state is HomeLoaded) {
                      final tareas = state.tareas;
                      return ListView.builder(
                        itemCount: tareas.length,
                        itemBuilder: (context, index) {
                          final tarea = tareas[index].data() as Map<String, dynamic>;
                          return _buildBeautifulTask(
                            tarea['nombre'] ?? 'Sin título',
                            tarea['detalle'] ?? 'Sin detalle',
                            tarea['estado'] ?? 'Sin estado',
                            index,
                          );
                        },
                      );
                    } else if (state is HomeEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7C3AED).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.assignment_outlined,
                                size: 80,
                                color: Color(0xFF7C3AED),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "¡No hay tareas para hoy!",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4A148C),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Disfruta tu día libre 🎉",
                              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      );
                    } else if (state is HomeError) {
                      return Center(child: Text("Error: ${state.error}"));
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBeautifulTask(String title, String subtitle, String estado, int index) {
    // Determinar el color según el estado
    Color statusColor = const Color(0xFF7C3AED);
    IconData statusIcon = Icons.pending_actions;
    
    if (estado.toLowerCase().contains('completada') || estado.toLowerCase().contains('terminada')) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (estado.toLowerCase().contains('pendiente')) {
      statusColor = Colors.orange;
      statusIcon = Icons.schedule;
    } else if (estado.toLowerCase().contains('proceso')) {
      statusColor = Colors.blue;
      statusIcon = Icons.play_circle;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18), // Más redondeado
        border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            // Animación de tap
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icono de estado con mejor diseño
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Contenido de la tarea
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D1B69),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      
                      // Estado con mejor diseño
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
                        ),
                        child: Text(
                          estado,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Indicador visual
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}