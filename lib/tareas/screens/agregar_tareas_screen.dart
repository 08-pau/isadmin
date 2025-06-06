import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/agregar_tarea_bloc.dart';

class AgregarTareasScreen extends StatefulWidget {
  const AgregarTareasScreen({super.key});

  @override
  State<AgregarTareasScreen> createState() => _AgregarTareasScreenState();
}

class _AgregarTareasScreenState extends State<AgregarTareasScreen> {
  final _nombreController = TextEditingController();
  final _detalleController = TextEditingController();
  DateTime _fechaInicio = DateTime.now();
  DateTime _fechaFin = DateTime.now();

  // Paleta de colores morados consistente
  final Color primaryPurple = const Color(0xFF7C3AED);
  final Color lightPurple = const Color(0xFFB794F4);
  final Color deepPurple = const Color(0xFF5B21B6);
  final Color purpleAccent = const Color(0xFFEDE9FE);
  final Color cardBackground = const Color(0xFFFAFAFC);
  final Color softPurple = const Color(0xFFF3F0FF);
  final Color mediumPurple = const Color(0xFF9F7AEA);

  Future<void> _pickDate(bool isInicio) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isInicio ? _fechaInicio : _fechaFin,
      firstDate: DateTime(2020),
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
    if (date != null) {
      setState(() {
        if (isInicio) {
          _fechaInicio = date;
        } else {
          _fechaFin = date;
        }
      });
    }
  }

  void _enviar() {
    final nombre = _nombreController.text.trim();
    final detalle = _detalleController.text.trim();

    if (nombre.isEmpty || detalle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Todos los campos son obligatorios'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }

    context.read<AgregarTareaBloc>().add(EnviarTarea(
      nombre: nombre,
      detalle: detalle,
      fechaInicio: _fechaInicio,
      fechaFin: _fechaFin,
    ));
  }

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
          child: BlocListener<AgregarTareaBloc, AgregarTareaState>(
            listener: (context, state) {
              if (state is AgregarTareaSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Tarea agregada exitosamente'),
                    backgroundColor: primaryPurple,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                );
                Navigator.pop(context);
              } else if (state is AgregarTareaError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${state.mensaje}'),
                    backgroundColor: Colors.red[400],
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                );
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  // Header elegante
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        // Botón de retroceso personalizado
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withOpacity(0.25)),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Icono principal
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
                            Icons.add_task_rounded,
                            size: 27,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Nueva Tarea',
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
                  
                  // Sección: Nombre de la Tarea
                  _buildSectionCard(
                    title: 'Nombre de la Tarea',
                    child: _buildTextField(
                      controller: _nombreController,
                      hintText: 'Ej. Leer capítulo 3',
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Sección: Fechas
                  _buildSectionCard(
                    title: 'Fechas',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fecha de Inicio',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: mediumPurple,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDateSelector(
                          date: _fechaInicio,
                          onTap: () => _pickDate(true),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Fecha de Fin',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: mediumPurple,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDateSelector(
                          date: _fechaFin,
                          onTap: () => _pickDate(false),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Sección: Detalle de la Tarea
                  _buildSectionCard(
                    title: 'Detalle de la Tarea',
                    child: Container(
                      decoration: BoxDecoration(
                        color: purpleAccent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: lightPurple.withOpacity(0.4)),
                      ),
                      child: TextField(
                        controller: _detalleController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Describe los detalles de la tarea...',
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
                  
                  // Botón de agregar tarea
                  BlocBuilder<AgregarTareaBloc, AgregarTareaState>(
                    builder: (context, state) {
                      return Container(
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
                          onPressed: state is AgregarTareaLoading ? null : _enviar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: state is AgregarTareaLoading
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
                                      Icons.add_task_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      "Agregar Tarea",
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
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
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
}