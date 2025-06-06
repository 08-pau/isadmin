import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../bloc/notas_bloc.dart';
import '../bloc/notas_event.dart';
import '../bloc/notas_state.dart';
import 'package:isadmin/notas/services/voz_service.dart';

class NotesHomeScreen extends StatelessWidget {
  const NotesHomeScreen({super.key});

  void _abrirModal(BuildContext context, {DocumentSnapshot? notaExistente}) {
    final TextEditingController controller = TextEditingController(
      text: notaExistente != null ? notaExistente['contenido'] : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 30,
          top: 30,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              notaExistente != null ? 'Editar Nota' : 'Agregar Nota',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7C3AED),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Escriba o dicte su nota aquí...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final texto = await VozService.iniciarReconocimiento();
                      if (texto != null && texto.isNotEmpty) {
                        controller.text += '$texto ';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Texto dictado: $texto'),
                            backgroundColor: const Color(0xFF7C3AED),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No se detectó voz. Intenta de nuevo.'),
                            backgroundColor: Colors.redAccent,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.mic, color: Colors.white),
                    label: const Text('Dictar', style: TextStyle(color: Colors.white, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final contenido = controller.text.trim();
                  if (contenido.isNotEmpty) {
                    if (notaExistente != null) {
                      context.read<NotasBloc>().add(EditarNota(notaExistente.id, contenido));
                    } else {
                      context.read<NotasBloc>().add(AgregarNota(contenido));
                    }
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text('Guardar Nota', style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF7C3AED);

    // Asegura que se carguen las notas al entrar
    context.read<NotasBloc>().add(CargarNotas());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Notas rápidas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: BlocBuilder<NotasBloc, NotasState>(
        builder: (context, state) {
          if (state is NotasLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotasLoaded) {
            final notas = state.notas;

            if (notas.isEmpty) {
              return const Center(
                child: Text('No hay notas aún', style: TextStyle(fontSize: 18, color: Colors.black54)),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                itemCount: notas.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final nota = notas[index];

                  return GestureDetector(
                    onTap: () => _abrirModal(context, notaExistente: nota),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                         Row(
  children: [
    Expanded(
      child: Text(
        'Nota',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: primaryColor, // ✅ Ahora sí se ve sobre fondo claro
        ),
      ),
    ),
    GestureDetector(
      onTap: () {
        context.read<NotasBloc>().add(EliminarNota(nota.id));
      },
      child: const Icon(Icons.close, size: 18, color: Colors.red),
    ),
  ],
),

                          const SizedBox(height: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(nota['contenido'], style: const TextStyle(color: Colors.black87)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return const Center(child: Text('Error al cargar notas'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
        onPressed: () => _abrirModal(context),
      ),
    );
  }
}
