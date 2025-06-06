import 'package:cloud_firestore/cloud_firestore.dart';

class CalificacionesRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot>> obtenerCalificaciones(String materiaId) async {
    final snapshot = await _db
        .collection('materias')
        .doc(materiaId)
        .collection('calificaciones')
        .orderBy('createdAt')
        .get();

    return snapshot.docs;
  }

  Future<void> agregarCalificacion({
    required String materiaId,
    required String nombre,
    required double nota,
    required double porcentajeObtenido,
    required double porcentajeTotal,
  }) async {
    await _db.collection('materias').doc(materiaId).collection('calificaciones').add({
      'nombre': nombre,
      'nota': nota,
      'porcentaje obtenido': porcentajeObtenido,
      'porcentaje total': porcentajeTotal,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> editarCalificacion({
    required String materiaId,
    required String calificacionId,
    required String nombre,
    required double nota,
    required double porcentajeObtenido,
    required double porcentajeTotal,
  }) async {
    await _db
        .collection('materias')
        .doc(materiaId)
        .collection('calificaciones')
        .doc(calificacionId)
        .update({
      'nombre': nombre,
      'nota': nota,
      'porcentaje obtenido': porcentajeObtenido,
      'porcentaje total': porcentajeTotal,
    });
  }

  Future<void> eliminarCalificacion({
    required String materiaId,
    required String calificacionId,
  }) async {
    await _db
        .collection('materias')
        .doc(materiaId)
        .collection('calificaciones')
        .doc(calificacionId)
        .delete();
  }
}
