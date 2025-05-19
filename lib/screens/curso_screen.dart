import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'ActividadesScreen.dart';
import 'ListaArchivosScreen.dart';

class CursoScreen extends StatelessWidget {
  final String materiaId;

  const CursoScreen({super.key, required this.materiaId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7C3AED),
      appBar: AppBar(
        title: const Text('Curso'),
        backgroundColor: const Color(0xFF7C3AED),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          CircularPercentIndicator(
            radius: 80.0,
            lineWidth: 12.0,
            animation: true,
            percent: 0.75,
            center: const Text(
              "75%",
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: Colors.white,
            backgroundColor: Colors.white24,
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                const Text(
                  'Opciones',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7C3AED),
                  ),
                ),
                const SizedBox(height: 20),
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
                            builder: (context) => CalificacionesScreen(materiaId: materiaId),
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
          CircleAvatar(
            backgroundColor: const Color(0xFF7C3AED),
            radius: 30,
            child: Icon(icono, size: 30, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7C3AED),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class CalificacionesScreen extends StatefulWidget {
  final String materiaId;

  const CalificacionesScreen({super.key, required this.materiaId});

  @override
  State<CalificacionesScreen> createState() => _CalificacionesScreenState();
}

class _CalificacionesScreenState extends State<CalificacionesScreen> {
  void _agregarCalificacion() {
    String nombre = '';
    double nota = 0, porcentajeObtenido = 0, porcentajeTotal = 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Calificación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Nombre del trabajo'),
              onChanged: (value) => nombre = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Nota obtenida'),
              keyboardType: TextInputType.number,
              onChanged: (value) => nota = double.tryParse(value) ?? 0,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Porcentaje obtenido'),
              keyboardType: TextInputType.number,
              onChanged: (value) => porcentajeObtenido = double.tryParse(value) ?? 0,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Porcentaje total'),
              keyboardType: TextInputType.number,
              onChanged: (value) => porcentajeTotal = double.tryParse(value) ?? 0,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Agregar'),
            onPressed: () async {
              if (nombre.isNotEmpty && porcentajeTotal > 0) {
                await FirebaseFirestore.instance
                    .collection('materias')
                    .doc(widget.materiaId)
                    .collection('calificaciones')
                    .add({
                  'nombre': nombre,
                  'nota': nota,
                  'porcentaje obtenido': porcentajeObtenido,
                  'porcentaje total': porcentajeTotal,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  double _calcularProgreso(List<QueryDocumentSnapshot> calificaciones) {
    double total = 0;
    double logrado = 0;

    for (var doc in calificaciones) {
      final obtenido = (doc['porcentaje obtenido'] as num).toDouble();
      final totalItem = (doc['porcentaje total'] as num).toDouble();
      total += totalItem;
      logrado += obtenido;
    }

    if (total == 0) return 0;
    return logrado / total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calificaciones'),
        backgroundColor: const Color(0xFF7C3AED),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('materias')
            .doc(widget.materiaId)
            .collection('calificaciones')
            .orderBy('createdAt')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          final progreso = _calcularProgreso(docs).clamp(0.0, 1.0).toDouble();

          return Column(
            children: [
              const SizedBox(height: 20),
              CircularPercentIndicator(
                radius: 80.0,
                lineWidth: 12.0,
                animation: true,
                percent: progreso,
                center: Text(
                  '${(progreso * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: const Color(0xFF7C3AED),
                backgroundColor: Colors.grey.shade300,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: docs.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay calificaciones aún',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final nombre = doc['nombre'];
                          final nota = (doc['nota'] as num).toDouble();
                          final obtenido = (doc['porcentaje obtenido'] as num).toDouble();
                          final total = (doc['porcentaje total'] as num).toDouble();
                          final porcentajeFinal = ((obtenido / total) * 100).toStringAsFixed(1);

                          return ListTile(
                            title: Text(nombre),
                            subtitle: Text('Nota: $nota - Obtenido: $obtenido% / Total: $total%'),
                            trailing: Text(
                              '$porcentajeFinal%',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7C3AED),
        child: const Icon(Icons.add),
        onPressed: _agregarCalificacion,
      ),
    );
  }
}

