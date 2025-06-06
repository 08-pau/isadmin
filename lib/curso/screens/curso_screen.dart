import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../actividades/screens/actividades_screen.dart';
import '../../nube/screens/lista_archivos_screen.dart';
import '../../calificaciones/screens/calificaciones_screen.dart';
import '../bloc/curso_bloc.dart';
import '../bloc/curso_event.dart';
import '../bloc/curso_state.dart';

class CursoScreen extends StatelessWidget {
  final String materiaId;

  const CursoScreen({super.key, required this.materiaId});

  @override
  Widget build(BuildContext context) {
    // Paleta de colores morados consistente
    final Color primaryPurple = const Color(0xFF7C3AED);
    final Color lightPurple = const Color(0xFFB794F4);
    final Color deepPurple = const Color(0xFF5B21B6);

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
        child: BlocBuilder<CursoBloc, CursoState>(
          builder: (context, state) {
            double progreso = 0;
            if (state is CursoCargado) {
              progreso = state.progreso;
            }

            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'Curso',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: CircularPercentIndicator(
                          radius: 120.0,
                          lineWidth: 16.0,
                          animation: true,
                          percent: progreso,
                          center: Text(
                            '${(progreso * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 26.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7C3AED),
                            ),
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                          progressColor: const Color(0xFF7C3AED),
                          backgroundColor: Colors.grey.shade300,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Progreso general del curso',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Opciones',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7C3AED),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                OpcionBoton(
                                  icono: Icons.grade,
                                  titulo: 'Calificaciones',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CalificacionesScreen(materiaId: materiaId),
                                      ),
                                    );
                                  },
                                ),
                                OpcionBoton(
                                  icono: Icons.assignment,
                                  titulo: 'Actividades',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ActividadesScreen(materiaId: materiaId),
                                      ),
                                    );
                                  },
                                ),
                                OpcionBoton(
                                  icono: Icons.cloud,
                                  titulo: 'Nube',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ListaArchivosScreen(materiaId: materiaId),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class OpcionBoton extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final VoidCallback? onTap;

  const OpcionBoton({
    required this.icono,
    required this.titulo,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF7C3AED),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: Icon(icono, size: 32, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7C3AED),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

