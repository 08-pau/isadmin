import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../bloc/actividades_bloc.dart';
import '../bloc/actividades_event.dart';
import '../bloc/actividades_state.dart';
import 'create_task_screen.dart';
import 'EditActivityScreen.dart'; // <- Importación correcta

class ActividadesScreen extends StatefulWidget {
  final String materiaId;
  const ActividadesScreen({super.key, required this.materiaId});

  @override
  State<ActividadesScreen> createState() => _ActividadesScreenState();
}

class _ActividadesScreenState extends State<ActividadesScreen> {
  String estadoSeleccionado = 'pendiente';
  String busqueda = '';
  final Color violet = const Color(0xFF7C3AED);
  final dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    context.read<ActividadesBloc>().add(CargarActividades(widget.materiaId));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: violet,
        title: const Text('Actividades', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: violet,
            child: TextField(
              onChanged: (value) => setState(() => busqueda = value.toLowerCase()),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Buscar actividad...',
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
              final activa = estado == estadoSeleccionado;
              return ChoiceChip(
                label: Text(estado[0].toUpperCase() + estado.substring(1)),
                selected: activa,
                selectedColor: violet,
                onSelected: (_) => setState(() => estadoSeleccionado = estado),
                labelStyle: TextStyle(
                  color: activa ? Colors.white : Colors.black,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: BlocBuilder<ActividadesBloc, ActividadesState>(
              builder: (context, state) {
                if (state is ActividadesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ActividadesError) {
                  return Center(child: Text(state.mensaje));
                }

                if (state is ActividadesCargadas) {
                  final actividades = state.actividades.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final titulo = (data['titulo'] ?? '').toString().toLowerCase();
                    final estado = (data['estado'] ?? 'pendiente').toString();
                    return titulo.contains(busqueda) && estado == estadoSeleccionado;
                  }).toList();

                  if (actividades.isEmpty) {
                    return const Center(child: Text('No hay actividades en esta categoría.'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: actividades.length,
                    itemBuilder: (context, index) {
                      final actividad = actividades[index];
                      final data = actividad.data() as Map<String, dynamic>;
                      final id = actividad.id;
                      final estado = (data['estado'] ?? 'pendiente').toString();

                      final fechaEntrega = (data['fechaEntrega'] as Timestamp?)?.toDate();
                      final fechaTexto = fechaEntrega != null ? dateFormat.format(fechaEntrega) : 'Sin fecha';

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
                              data['titulo'] ?? '',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7C3AED),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(data['descripcion'] ?? '', style: const TextStyle(color: Colors.black87)),
                            const SizedBox(height: 6),
                            Text('Fecha: $fechaTexto', style: const TextStyle(color: Colors.black54)),
                            Text('Urgencia: ${data['urgencia'] ?? 'N/A'}', style: const TextStyle(color: Colors.black54)),
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
                                        context.read<ActividadesBloc>().add(
                                              CambiarEstadoActividad(
                                                materiaId: widget.materiaId,
                                                actividadId: id,
                                                nuevoEstado: 'completada',
                                              ),
                                            );
                                      },
                                      icon: const Icon(Icons.check, color: Colors.green),
                                      label: const Text("Completar"),
                                    ),
                                    TextButton.icon(
                                      onPressed: () {
                                        context.read<ActividadesBloc>().add(
                                              CambiarEstadoActividad(
                                                materiaId: widget.materiaId,
                                                actividadId: id,
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
                                            builder: (context) => EditActivityScreen(
                                              materiaId: widget.materiaId,
                                              actividadId: id,
                                              actividad: data,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        context.read<ActividadesBloc>().add(
                                              EliminarActividad(
                                                materiaId: widget.materiaId,
                                                actividadId: id,
                                              ),
                                            );
                                      },
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

                return const SizedBox();
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
              builder: (context) => CreateTaskScreen(materiaId: widget.materiaId),
            ),
          );
        },
      ),
    );
  }
}
