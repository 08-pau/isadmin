import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:isadmin/actividades/bloc/crear_actividad_bloc.dart';
import 'package:isadmin/actividades/bloc/crear_actividad_state.dart';
import 'package:isadmin/actividades/bloc/crear_actividad_event.dart';

class CreateTaskScreen extends StatefulWidget {
  final String materiaId;
  const CreateTaskScreen({super.key, required this.materiaId});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _taskNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _urgencyCategory = "Normal";
  bool _notify = false;
  DateTime _fechaEntrega = DateTime.now();
  DateTime _startRepeatDate = DateTime.now();
  DateTime _endRepeatDate = DateTime.now().add(const Duration(days: 1));
  List<TimeOfDay> _horasDelDia = [const TimeOfDay(hour: 8, minute: 0)];
  final List<String> _urgencyLevels = ["Baja", "Normal", "Urgente"];
  
  // Paleta de colores morados mejorada y extendida
  final Color primaryPurple = const Color(0xFF7C3AED);
  final Color lightPurple = const Color(0xFFB794F4);
  final Color deepPurple = const Color(0xFF5B21B6);
  final Color purpleAccent = const Color(0xFFEDE9FE);
  final Color cardBackground = const Color(0xFFFAFAFC);
  final Color softPurple = const Color(0xFFF3F0FF);
  final Color mediumPurple = const Color(0xFF9F7AEA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              deepPurple,
              primaryPurple,
              lightPurple,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<CrearActividadBloc, CrearActividadState>(
            listener: (context, state) {
              if (state is CrearActividadSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Actividad guardada exitosamente'),
                    backgroundColor: primaryPurple,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                );
                Navigator.pop(context);
              } else if (state is CrearActividadFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${state.error}'),
                    backgroundColor: Colors.red[400],
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                );
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  children: [
                    // Header mejorado con paleta de colores
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          // Icono de la app
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.25)),
                              boxShadow: [
                                BoxShadow(
                                  color: deepPurple.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.task_alt_rounded,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Nueva Actividad',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          
                        ],
                      ),
                    ),
                    
                    // Sección: Información Básica
                    _buildSectionCard(
                      title:'Título de la actividad',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _taskNameController,
                            hintText: 'Ej. Exposición de Historia',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Sección: Nivel de Urgencia con paleta de colores
                    _buildSectionCard(
                      title: 'Nivel de Urgencia',
                      child: Row(
                        children: _urgencyLevels.map((level) {
                          final selected = _urgencyCategory == level;
                          Color buttonColor;
                          Color textColor;
                          
                          switch (level) {
                            case 'Baja':
                              buttonColor = selected ? Colors.green[500]! : softPurple;
                              textColor = selected ? Colors.white : mediumPurple;
                              break;
                            case 'Normal':
                              buttonColor = selected ? Colors.orange[500]! : softPurple;
                              textColor = selected ? Colors.white : mediumPurple;
                              break;
                            case 'Urgente':
                              buttonColor = selected ? Colors.red[500]! : softPurple;
                              textColor = selected ? Colors.white : mediumPurple;
                              break;
                            default:
                              buttonColor = primaryPurple;
                              textColor = Colors.white;
                          }
                          
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: GestureDetector(
                                onTap: () => setState(() => _urgencyCategory = level),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: buttonColor,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: selected ? buttonColor : lightPurple.withOpacity(0.3),
                                      width: selected ? 0 : 1,
                                    ),
                                    boxShadow: selected ? [
                                      BoxShadow(
                                        color: buttonColor.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ] : [],
                                  ),
                                  child: Center(
                                    child: Text(
                                      level,
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Sección: Fecha de Entrega
                    _buildSectionCard(
                      title: 'Fecha de Entrega',
                      child: _buildDateSelector(
                        date: _fechaEntrega,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _fechaEntrega,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: primaryPurple,
                                    secondary: lightPurple,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (date != null) setState(() => _fechaEntrega = date);
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Sección: Notificaciones
                    _buildSectionCard(
                      title: 'Notificaciones',
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: purpleAccent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: lightPurple.withOpacity(0.4)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.notifications_active_rounded,
                                    color: primaryPurple,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      '¿Deseas recibir notificaciones?',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Transform.scale(
                                    scale: 0.9,
                                    child: Switch(
                                      value: _notify,
                                      onChanged: (val) => setState(() => _notify = val),
                                      activeColor: primaryPurple,
                                      activeTrackColor: lightPurple.withOpacity(0.5),
                                      inactiveThumbColor: Colors.grey[400],
                                      inactiveTrackColor: Colors.grey[300],
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Opciones adicionales de notificación
                          if (_notify) ...[
                            const SizedBox(height: 24),
                            _buildNotificationOptions(),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Sección: Descripción
                    _buildSectionCard(
                      title: 'Descripción',
                      child: Container(
                        decoration: BoxDecoration(
                          color: purpleAccent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: lightPurple.withOpacity(0.4)),
                        ),
                        child: TextField(
                          controller: _descriptionController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Describe los detalles de la actividad...',
                            hintStyle: TextStyle(
                              color: mediumPurple.withOpacity(0.7),
                              fontSize: 15,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(20),
                          ),
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Botón de guardar mejorado con gradiente de la paleta
                    Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryPurple, deepPurple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: primaryPurple.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: state is CrearActividadLoading
                            ? null
                            : () {
                                context.read<CrearActividadBloc>().add(
                                      CrearActividadRequested(
                                        materiaId: widget.materiaId,
                                        titulo: _taskNameController.text.trim(),
                                        descripcion: _descriptionController.text.trim(),
                                        urgencia: _urgencyCategory,
                                        fechaEntrega: _fechaEntrega,
                                        notificar: _notify,
                                        horasNotificacion: _horasDelDia
                                            .map((h) =>
                                                "${h.hour}:${h.minute.toString().padLeft(2, '0')}")
                                            .toList(),
                                        fechaInicioRango: _startRepeatDate,
                                        fechaFinRango: _endRepeatDate,
                                        estado: 'pendiente',
                                      ),
                                    );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: state is CrearActividadLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.save_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "Guardar Actividad",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: deepPurple,
              ),
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: purpleAccent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: lightPurple.withOpacity(0.4)),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: mediumPurple.withOpacity(0.7),
            fontSize: 15,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDateSelector({
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: purpleAccent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: lightPurple.withOpacity(0.4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryPurple, deepPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: primaryPurple.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                DateFormat('dd/MM/yyyy').format(date),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                color: mediumPurple,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rango de notificación',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: deepPurple,
          ),
        ),
        const SizedBox(height: 16),
        _buildDateSelector(
          date: _startRepeatDate,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _startRepeatDate,
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: primaryPurple,
                      secondary: lightPurple,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) setState(() => _startRepeatDate = date);
          },
        ),
        const SizedBox(height: 12),
        _buildDateSelector(
          date: _endRepeatDate,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _endRepeatDate,
              firstDate: _startRepeatDate,
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: primaryPurple,
                      secondary: lightPurple,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) setState(() => _endRepeatDate = date);
          },
        ),
        const SizedBox(height: 24),
        Text(
          'Horas de notificación',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: deepPurple,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: softPurple,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: lightPurple.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              ..._horasDelDia.asMap().entries.map((entry) {
                final i = entry.key;
                final hora = entry.value;
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryPurple.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryPurple, mediumPurple],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.access_time_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        hora.format(context),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete_outline_rounded, 
                          color: Colors.red[400],
                        ),
                        onPressed: () => setState(() => _horasDelDia.removeAt(i)),
                      ),
                    ),
                  ),
                );
              }),
              Padding(
                padding: const EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 8, minute: 0),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: primaryPurple,
                              secondary: lightPurple,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) setState(() => _horasDelDia.add(picked));
                  },
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: lightPurple, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: lightPurple.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_rounded, color: primaryPurple, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          "Agregar hora",
                          style: TextStyle(
                            color: primaryPurple,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}