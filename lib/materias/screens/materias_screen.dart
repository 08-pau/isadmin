import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/materias_bloc.dart';
import '../bloc/materias_event.dart';
import '../bloc/materias_state.dart';
import '../../curso/screens/curso_screen.dart';
import 'agregar_materia_screen.dart';

class MateriasScreen extends StatefulWidget {
  const MateriasScreen({super.key});

  @override
  State<MateriasScreen> createState() => _MateriasScreenState();
}

class _MateriasScreenState extends State<MateriasScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MateriasBloc>().add(CargarMaterias());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E8FF),
      appBar: AppBar(
        title: const Text("Materias", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF7C3AED),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                context.read<MateriasBloc>().add(BuscarMaterias(value));
              },
              decoration: InputDecoration(
                hintText: "Buscar la materia...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BlocBuilder<MateriasBloc, MateriasState>(
                builder: (context, state) {
                  if (state is MateriasCargando) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is MateriasError) {
                    return Center(child: Text(state.mensaje));
                  }

                  if (state is MateriasCargadas) {
                    final materias = state.materias;
                    if (materias.isEmpty) {
                      return const Center(child: Text("No hay materias registradas"));
                    }

                    return GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: materias.map((doc) {
                        final nombre = doc['nombre'] ?? 'Sin nombre';
                        final profesor = doc['profesor'] ?? 'Sin profesor';
                        final materiaId = doc['id'];

                        return MateriaCard(
                          materiaId: materiaId,
                          titulo: nombre,
                          profesor: profesor,
                        );
                      }).toList(),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7C3AED),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AgregarMateriaScreen()),
          );
          context.read<MateriasBloc>().add(RefrescarMaterias());
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class MateriaCard extends StatelessWidget {
  final String materiaId;
  final String titulo;
  final String profesor;

  const MateriaCard({
    super.key,
    required this.materiaId,
    required this.titulo,
    required this.profesor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CursoScreen(materiaId: materiaId)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF7C3AED), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.book_outlined, color: Color(0xFF7C3AED), size: 28),
                const Spacer(),
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Color(0xFF7C3AED),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  profesor,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                onTap: () {
                  context.read<MateriasBloc>().add(EliminarMateria(materiaId));
                },
                child: const CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}