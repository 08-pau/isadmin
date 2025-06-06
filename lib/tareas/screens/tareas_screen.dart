import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isadmin/tareas/bloc/tareas_bloc.dart';
import 'agregar_tareas_screen.dart';
import 'editar_tarea_screen.dart';

class TareasScreen extends StatefulWidget {
  const TareasScreen({super.key});

  @override
  State<TareasScreen> createState() => _TareasScreenState();
}

class _TareasScreenState extends State<TareasScreen> {
  String categoriaSeleccionada = 'pendiente';
  String busqueda = '';
  final violet = const Color(0xFF7C3AED);
  final dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    context.read<TareasBloc>().add(CargarTareas(categoriaSeleccionada));
  }

  Color _getColorEstado(String estado) {
    switch (estado) {
      case 'completada':
        return Colors.green;
      case 'anulada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _confirmarEliminacion(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Eliminar tarea?'),
        content: const Text('¿Estás seguro de que deseas eliminar esta tarea?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TareasBloc>().add(EliminarTarea(id));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: violet),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: violet,
        elevation: 0,
        title: const Text('Tareas', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
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
                hintText: 'Buscar...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['pendiente', 'completada', 'anulada'].map((estado) {
              final activa = estado == categoriaSeleccionada;
              return ChoiceChip(
                label: Text(estado[0].toUpperCase() + estado.substring(1)),
                selected: activa,
                selectedColor: violet,
                onSelected: (_) {
                  setState(() {
                    categoriaSeleccionada = estado;
                  });
                  context.read<TareasBloc>().add(CargarTareas(estado));
                },
                labelStyle: TextStyle(
                  color: activa ? Colors.white : Colors.black,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: BlocBuilder<TareasBloc, TareasState>(
              builder: (context, state) {
                if (state is TareasLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is TareasError) {
                  return Center(child: Text(state.mensaje));
                }

                if (state is TareasCargadas) {
                  final tareas = state.tareas.where((doc) {
                    final nombre = (doc['nombre'] ?? '').toString().toLowerCase();
                    return nombre.contains(busqueda);
                  }).toList();

                  if (tareas.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/tarea.jpeg', width: 250, height: 250),
                          const SizedBox(height: 16),
                          const Text("No se encontraron tareas.", style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: tareas.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final tarea = tareas[index];
                      final id = tarea.id;
                      final data = tarea.data() as Map<String, dynamic>;
                      final estado = (data['estado'] ?? 'pendiente').toString();

                      final fechaInicio = (data['fechaInicio'] as Timestamp?)?.toDate();
                      final fechaFin = (data['fechaFin'] as Timestamp?)?.toDate();

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
                            Text(
                              data['nombre'] ?? 'Sin título',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7C3AED),
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (fechaInicio != null && fechaFin != null)
                              Text(
                                "Del ${dateFormat.format(fechaInicio)} al ${dateFormat.format(fechaFin)}",
                                style: const TextStyle(color: Colors.black54),
                              ),
                            const SizedBox(height: 10),
                            LinearProgressIndicator(
                              value: estado == 'completada' ? 1.0 : 0.0,
                              backgroundColor: Colors.grey[300],
                              color: _getColorEstado(estado),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    TextButton.icon(
                                      onPressed: () {
                                        context.read<TareasBloc>().add(
                                              CambiarEstadoTarea(
                                                id: id,
                                                nuevoEstado: 'completada',
                                              ),
                                            );
                                      },
                                      icon: const Icon(Icons.check, color: Colors.green),
                                      label: const Text("Completar"),
                                    ),
                                    TextButton.icon(
                                      onPressed: () {
                                        context.read<TareasBloc>().add(
                                              CambiarEstadoTarea(
                                                id: id,
                                                nuevoEstado: 'anulada',
                                              ),
                                            );
                                      },
                                      icon: const Icon(Icons.cancel, color: Colors.red),
                                      label: const Text("Anular"),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Color(0xFF7C3AED)),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditTaskScreen(
                                              id: id,
                                              tarea: data,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _confirmarEliminacion(id),
                                    ),
                                  ],
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
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AgregarTareasScreen(),
            ),
          );
        },
      ),
    );
  }
}
