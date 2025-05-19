import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'UploadScreen.dart';

class ListaArchivosScreen extends StatefulWidget {
  final String materiaId;
  const ListaArchivosScreen({super.key, required this.materiaId});

  @override
  State<ListaArchivosScreen> createState() => _ListaArchivosScreenState();
}

class _ListaArchivosScreenState extends State<ListaArchivosScreen> {
  String _filtro = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Archivos de la nube',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF7C3AED),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
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
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('materias')
                  .doc(widget.materiaId)
                  .collection('nube')
                  .orderBy('fecha', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final archivos = snapshot.data!.docs.where((doc) {
                  final descripcion = (doc['descripcion'] ?? '').toString().toLowerCase();
                  return descripcion.contains(_filtro);
                }).toList();

                if (archivos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off, size: 60, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text(
                          'No hay archivos que coincidan.',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Sube archivos o imágenes aquí',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.upload_file, color: Colors.white),
                          label: const Text('Subir archivo', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C3AED),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UploadScreen(materiaId: widget.materiaId),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: archivos.length,
                  itemBuilder: (context, index) {
                    final doc = archivos[index];
                    final tipo = doc['tipo'];
                    final url = doc['url'];
                    final descripcion = doc['descripcion'];
                    final fecha = (doc['fecha'] as Timestamp).toDate();
                    final fechaTexto = DateFormat('dd/MM/yyyy – HH:mm').format(fecha);

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
                                child: Image.network(url, width: 60, height: 60, fit: BoxFit.cover),
                              )
                            : const Icon(Icons.insert_drive_file, size: 40, color: Color(0xFF7C3AED)),
                        title: Text(
                          descripcion,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Fecha: $fechaTexto'),
                        trailing: IconButton(
                          icon: const Icon(Icons.download, color: Color(0xFF7C3AED)),
                          onPressed: () async {
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('No se pudo abrir el archivo')),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7C3AED),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UploadScreen(materiaId: widget.materiaId),
            ),
          );
        },
      ),
    );
  }
}
