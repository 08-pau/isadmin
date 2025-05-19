import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'agregar_materia_screen.dart';
import 'curso_screen.dart';

class MateriasScreen extends StatefulWidget {
  const MateriasScreen({super.key});

  @override
  State<MateriasScreen> createState() => _MateriasScreenState();
}

class _MateriasScreenState extends State<MateriasScreen> {
  String _busqueda = '';

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
            // Buscador
            TextField(
              onChanged: (value) {
                setState(() {
                  _busqueda = value.trim().toLowerCase();
                });
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

            // Lista dinámica desde Firebase
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('materias')
                    .orderBy('nombre')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No hay materias registradas"));
                  }

                  final materiasFiltradas = snapshot.data!.docs.where((doc) {
                    final nombre = (doc['nombre'] ?? '').toString().toLowerCase();
                    return nombre.contains(_busqueda);
                  }).toList();

                  return GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: materiasFiltradas.map((doc) {
                      final nombre = doc['nombre'] ?? 'Sin nombre';
                      final profesor = doc['profesor'] ?? 'Sin profesor';

                      return MateriaCard(
                        materiaId: doc.id,
                        titulo: nombre,
                        profesor: profesor,
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7C3AED),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AgregarMateriaScreen()),
          );
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
        child: Column(
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
      ),
    );
  }
}
