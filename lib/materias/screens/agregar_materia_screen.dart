import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/agregar_materia_bloc.dart';

class AgregarMateriaScreen extends StatefulWidget {
  const AgregarMateriaScreen({super.key});

  @override
  State<AgregarMateriaScreen> createState() => _AgregarMateriaScreenState();
}

class _AgregarMateriaScreenState extends State<AgregarMateriaScreen> {
  final nombreController = TextEditingController();
  final profesorController = TextEditingController();
  final horarioController = TextEditingController();

  // Paleta de colores morados consistente
  final Color primaryPurple = const Color(0xFF7C3AED);
  final Color lightPurple = const Color(0xFFB794F4);
  final Color deepPurple = const Color(0xFF5B21B6);
  final Color purpleAccent = const Color(0xFFEDE9FE);
  final Color cardBackground = const Color(0xFFFAFAFC);
  final Color softPurple = const Color(0xFFF3F0FF);
  final Color mediumPurple = const Color(0xFF9F7AEA);

  void _enviarMateria() {
    final nombre = nombreController.text.trim();
    final profesor = profesorController.text.trim();
    final horario = horarioController.text.trim();

    if (nombre.isEmpty || profesor.isEmpty || horario.isEmpty) {
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

    context.read<AgregarMateriaBloc>().add(EnviarMateria(
      nombre: nombre,
      profesor: profesor,
      horario: horario,
    ));
  }

  void _mostrarDialogo(BuildContext context, String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
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
          child: BlocListener<AgregarMateriaBloc, AgregarMateriaState>(
            listener: (context, state) {
              if (state is AgregarMateriaSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Materia agregada exitosamente'),
                    backgroundColor: primaryPurple,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                );
                nombreController.clear();
                profesorController.clear();
                horarioController.clear();
                Navigator.pop(context);
              } else if (state is AgregarMateriaError) {
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
                            Icons.school_rounded,
                            size: 27,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Nueva Materia',
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
                  
                  // Sección: Nombre de la Materia
                  _buildSectionCard(
                    title: 'Nombre de la Materia',
                    child: _buildTextField(
                      controller: nombreController,
                      hintText: 'Ej. Matemáticas, Historia, etc.',
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Sección: Profesor
                  _buildSectionCard(
                    title: 'Nombre del Profesor',
                    child: _buildTextField(
                      controller: profesorController,
                      hintText: 'Ej. Dr. Juan Pérez',
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Sección: Horario
                  _buildSectionCard(
                    title: 'Horario',
                    child: _buildTextField(
                      controller: horarioController,
                      hintText: 'Ej. Lunes 10:00 AM - 12:00 PM',
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Botón de agregar materia
                  BlocBuilder<AgregarMateriaBloc, AgregarMateriaState>(
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
                          onPressed: state is AgregarMateriaLoading ? null : _enviarMateria,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: state is AgregarMateriaLoading
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
                                      "Guardar Materia",
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
}