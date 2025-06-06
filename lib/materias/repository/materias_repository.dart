import 'package:cloud_firestore/cloud_firestore.dart';

class MateriasRepository {
  final _materiasRef = FirebaseFirestore.instance.collection('materias');

  // Buscar materias por nombre

  Future<List<Map<String, dynamic>>> obtenerMaterias() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('materias')
        .orderBy('nombre')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }
Future<void> eliminarMateria(String id) async {
  await _materiasRef.doc(id).delete();
}

  // Agregar una nueva materia
  Future<void> agregarMateria({
    required String nombre,
    required String profesor,
    required String horario,
  }) async {
    await _materiasRef.add({
      'nombre': nombre,
      'profesor': profesor,
      'horario': horario,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
