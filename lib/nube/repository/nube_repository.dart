import 'package:cloud_firestore/cloud_firestore.dart';

class NubeRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot>> obtenerArchivos(String materiaId) async {
    final snapshot = await _db
        .collection('materias')
        .doc(materiaId)
        .collection('nube')
        .orderBy('fecha', descending: true)
        .get();
    return snapshot.docs;
  }

  Future<void> eliminarArchivo(String materiaId, String archivoId) async {
    await _db
        .collection('materias')
        .doc(materiaId)
        .collection('nube')
        .doc(archivoId)
        .delete();
  }
}

