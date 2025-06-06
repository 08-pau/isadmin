import 'package:cloud_firestore/cloud_firestore.dart';

class TareasRepository {
  final _ref = FirebaseFirestore.instance.collection('tareas');

  // Agregar nueva tarea
  Future<void> agregarTarea({
    required String nombre,
    required String detalle,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    await _ref.add({
      'nombre': nombre,
      'detalle': detalle,
      'fechaInicio': fechaInicio,
      'fechaFin': fechaFin,
      'estado': 'pendiente',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Editar tarea existente
  Future<void> editarTarea({
    required String id,
    required String nombre,
    required String estado,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    await _ref.doc(id).update({
      'nombre': nombre,
      'estado': estado,
      'fechaInicio': fechaInicio,
      'fechaFin': fechaFin,
    });
  }

  // Obtener tareas por estado
  Future<List<QueryDocumentSnapshot>> obtenerTareasPorEstado(String estado) async {
    final snapshot = await _ref.where('estado', isEqualTo: estado).get();
    return snapshot.docs;
  }

  // Cambiar estado de una tarea
  Future<void> cambiarEstado(String id, String nuevoEstado) async {
    await _ref.doc(id).update({'estado': nuevoEstado});
  }

  // Eliminar tarea
  Future<void> eliminarTarea(String id) async {
    await _ref.doc(id).delete();
  }
}
