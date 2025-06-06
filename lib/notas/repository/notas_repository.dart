import 'package:cloud_firestore/cloud_firestore.dart';

class NotasRepository {
  final CollectionReference notasRef = FirebaseFirestore.instance.collection('notas');

  Future<QuerySnapshot> obtenerNotas() {
    return notasRef.orderBy('fechaCreacion', descending: true).get();
  }

  Future<void> agregarNota(String contenido) {
    return notasRef.add({
      'contenido': contenido,
      'fechaCreacion': FieldValue.serverTimestamp(),
    });
  }

  Future<void> editarNota(String id, String nuevoContenido) {
    return notasRef.doc(id).update({'contenido': nuevoContenido});
  }

  Future<void> eliminarNota(String id) {
    return notasRef.doc(id).delete();
  }
}
