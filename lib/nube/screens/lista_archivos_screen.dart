import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:isadmin/nube/bloc/nube_bloc.dart';
import 'package:isadmin/nube/bloc/nube_event.dart';
import 'package:isadmin/nube/bloc/nube_state.dart';
import 'package:isadmin/nube/screens/upload_screen.dart';

class ListaArchivosScreen extends StatefulWidget {
  final String materiaId;

  const ListaArchivosScreen({super.key, required this.materiaId});

  @override
  State<ListaArchivosScreen> createState() => _ListaArchivosScreenState();
}

class _ListaArchivosScreenState extends State<ListaArchivosScreen> {
  String _filtro = '';

  @override
  void initState() {
    super.initState();
    context.read<NubeBloc>().add(CargarArchivos(materiaId: widget.materiaId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archivos de la nube', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF7C3AED),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Buscar por descripción',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF7C3AED)),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (valor) {
                setState(() {
                  _filtro = valor.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<NubeBloc, NubeState>(
              builder: (context, state) {
                if (state is NubeLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is NubeError) {
                  return const Center(child: Text('Error al cargar archivos.'));
                } else if (state is NubeLoaded) {
                  final archivos = state.archivos.where((archivo) {
                    return archivo['descripcion']
                        .toString()
                        .toLowerCase()
                        .contains(_filtro);
                  }).toList();

                  if (archivos.isEmpty) {
                    return _buildVacio(context);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: archivos.length,
                    itemBuilder: (context, index) {
                      final archivo = archivos[index];
                      final fecha = (archivo['fecha'] as Timestamp).toDate();
                      final fechaTexto = DateFormat('dd/MM/yyyy – HH:mm').format(fecha);
                      final descripcion = archivo['descripcion'] ?? '';
                      final url = archivo['url'] ?? '';
                      final tipo = archivo['tipo'] ?? '';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7C3AED).withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: const Color(0xFF7C3AED), width: 1.2),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: tipo == 'imagen'
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    url,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(Icons.insert_drive_file, size: 40, color: Color(0xFF7C3AED)),
                          title: Text(
                            descripcion,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Fecha: $fechaTexto'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.download, color: Color(0xFF7C3AED)),
                                onPressed: () async {
                                  try {
                                    final uri = Uri.parse(url);
                                    final launched = await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                    if (!launched) throw 'No se pudo lanzar la URL';
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('❌ Error al abrir archivo: $e')),
                                    );
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _mostrarDialogoConfirmacion(context, archivo.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return _buildVacio(context);
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7C3AED),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UploadScreen(materiaId: widget.materiaId),
            ),
          );

          if (resultado == true) {
            context.read<NubeBloc>().add(CargarArchivos(materiaId: widget.materiaId));
          }
        },
      ),
    );
  }

  void _mostrarDialogoConfirmacion(BuildContext context, String archivoId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('¿Eliminar archivo?'),
          content: const Text('¿Estás seguro de que deseas eliminar este archivo? Esta acción no se puede deshacer.'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[700],
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<NubeBloc>().add(
                  EliminarArchivo(
                    materiaId: widget.materiaId,
                    archivoId: archivoId,
                  ),
                );
              },
              child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVacio(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 60, color: Colors.grey),
          const SizedBox(height: 12),
          const Text('No hay archivos que coincidan.', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Sube archivos o imágenes aquí', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.upload_file, color: Colors.white),
            label: const Text('Subir archivo', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final resultado = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UploadScreen(materiaId: widget.materiaId),
                ),
              );

              if (resultado == true) {
                context.read<NubeBloc>().add(CargarArchivos(materiaId: widget.materiaId));
              }
            },
          ),
        ],
      ),
    );
  }
}
