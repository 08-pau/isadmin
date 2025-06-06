import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../bloc/calificaciones_bloc.dart';
import '../bloc/calificaciones_event.dart';
import '../bloc/calificaciones_state.dart';
import 'agregar_calificacion_screen.dart';
import 'editar_calificacion_screen.dart';

class CalificacionesScreen extends StatefulWidget {
  final String materiaId;
  final String? materiaNombre;

  const CalificacionesScreen({
    super.key, 
    required this.materiaId,
    this.materiaNombre,
  });

  @override
  State<CalificacionesScreen> createState() => _CalificacionesScreenState();
}

class _CalificacionesScreenState extends State<CalificacionesScreen> {
  String busqueda = '';
  final violet = const Color(0xFF7C3AED);

  @override
  void initState() {
    super.initState();
    context.read<CalificacionesBloc>().add(CargarCalificaciones(widget.materiaId));
  }

  void _confirmarEliminacion(String calificacionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Eliminar calificación?'),
        content: const Text('¿Estás seguro de que deseas eliminar esta calificación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CalificacionesBloc>().add(
                EliminarCalificacion(
                  materiaId: widget.materiaId,
                  calificacionId: calificacionId,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: violet),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  double _calcularProgreso(List<QueryDocumentSnapshot> calificaciones) {
    double progreso = 0;
    for (var doc in calificaciones) {
      final obtenido = (doc['porcentaje obtenido'] as num).toDouble();
      progreso += obtenido;
    }
    return (progreso / 100).clamp(0.0, 1.0);
  }

  double _calcularNotaPromedio(List<QueryDocumentSnapshot> calificaciones) {
    if (calificaciones.isEmpty) return 0;
    double sumaNotas = 0;
    for (var doc in calificaciones) {
      final nota = (doc['nota'] as num).toDouble();
      sumaNotas += nota;
    }
    return sumaNotas / calificaciones.length;
  }

  Color _getColorNota(double nota) {
    if (nota >= 90) return Colors.green;
    if (nota >= 80) return Colors.lightGreen;
    if (nota >= 70) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: violet,
        elevation: 0,
        title: Text(
          widget.materiaNombre ?? 'Calificaciones',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.all(16),
            color: violet,
            child: TextField(
              onChanged: (value) {
                setState(() {
                  busqueda = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Buscar calificación...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          
          // Indicador de progreso
          BlocBuilder<CalificacionesBloc, CalificacionesState>(
            builder: (context, state) {
              if (state is CalificacionesCargadas) {
                final calificaciones = state.calificaciones;
                final progreso = _calcularProgreso(calificaciones);
                final notaPromedio = _calcularNotaPromedio(calificaciones);
                
                return Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Progreso circular
                      CircularPercentIndicator(
                        radius: 60.0,
                        lineWidth: 10.0,
                        animation: true,
                        percent: progreso,
                        center: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${(progreso * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Progreso',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        circularStrokeCap: CircularStrokeCap.round,
                        progressColor: violet,
                        backgroundColor: Colors.grey.shade300,
                      ),
                      
                      // Estadísticas
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _getColorNota(notaPromedio),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  notaPromedio.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Promedio',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${calificaciones.length} calificaciones',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox(height: 120);
            },
          ),
          
          const Divider(),
          
          // Lista de calificaciones
          Expanded(
            child: BlocBuilder<CalificacionesBloc, CalificacionesState>(
              builder: (context, state) {
                if (state is CalificacionesInicial || state is CalificacionesCargando) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is CalificacionesError) {
                  return Center(child: Text(state.mensaje));
                }

                if (state is CalificacionesCargadas) {
                  final calificaciones = state.calificaciones.where((doc) {
                    final nombre = (doc['nombre'] ?? '').toString().toLowerCase();
                    return nombre.contains(busqueda);
                  }).toList();

                  if (calificaciones.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/tarea.jpeg', width: 200, height: 200),
                          const SizedBox(height: 16),
                          Text(
                            busqueda.isEmpty 
                              ? "No hay calificaciones aún" 
                              : "No se encontraron calificaciones",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: calificaciones.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final doc = calificaciones[index];
                      final nombre = doc['nombre'];
                      final nota = (doc['nota'] as num).toDouble();
                      final obtenido = (doc['porcentaje obtenido'] as num).toDouble();
                      final total = (doc['porcentaje total'] as num).toDouble();
                      final porcentajeFinal = total > 0 ? (obtenido / total) * 100 : 0.0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: violet, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: violet.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: violet.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.assignment_turned_in,
                                    color: violet,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nombre,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: violet,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Nota: $nota',
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getColorNota(nota),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    nota.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Información de porcentajes
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Porcentaje obtenido: ${obtenido.toStringAsFixed(1)}%',
                                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                                      ),
                                      Text(
                                        'Porcentaje total: ${total.toStringAsFixed(1)}%',
                                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 10),
                            
                            // Barra de progreso
                            LinearProgressIndicator(
                              value: total > 0 ? (obtenido / total).clamp(0.0, 1.0) : 0,
                              backgroundColor: Colors.grey[300],
                              color: _getColorNota(porcentajeFinal),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Botones de acción
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: violet),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditarCalificacionScreen(
                                          materiaId: widget.materiaId,
                                          calificacionId: doc.id,
                                          calificacion: doc.data() as Map<String, dynamic>,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _confirmarEliminacion(doc.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: violet,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AgregarCalificacionScreen(
                materiaId: widget.materiaId,
              ),
            ),
          );
        },
      ),
    );
  }
}