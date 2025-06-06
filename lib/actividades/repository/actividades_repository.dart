import 'package:cloud_firestore/cloud_firestore.dart';

class ActividadesRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔄 Obtener actividades de una materia en tiempo real
  Stream<QuerySnapshot> obtenerActividades(String materiaId) {
    return _db
        .collection('materias')
        .doc(materiaId)
        .collection('actividades')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ✅ Agregar actividad con conversión segura a Timestamp
Future<void> agregarActividad({
  required String materiaId,
  required String titulo,
  required String descripcion,
  required String urgencia,
  required DateTime fechaEntrega,
  required bool notificar,
  required List<String> horasNotificacion,
  required DateTime fechaInicioRango,
  required DateTime fechaFinRango,
  required String estado, // NUEVO
}) async {
  try {
    await _db.collection('materias').doc(materiaId).collection('actividades').add({
      'titulo': titulo,
      'descripcion': descripcion,
      'urgencia': urgencia,
      'fechaEntrega': Timestamp.fromDate(fechaEntrega),
      'notificar': notificar,
      'horasNotification': horasNotificacion,
      'fechaInicioRango': Timestamp.fromDate(fechaInicioRango),
      'fechaFinRango': Timestamp.fromDate(fechaFinRango),
      'createdAt': FieldValue.serverTimestamp(),
      'estado': estado, // ✅ NUEVO CAMPO
    });
    print('✅ Actividad agregada correctamente');
  } catch (e) {
    print('❌ Error al agregar actividad: $e');
    rethrow;
  }
}
Future<void> cambiarEstadoActividad({
  required String materiaId,
  required String actividadId,
  required String nuevoEstado,
}) async {
  try {
    await _db
        .collection('materias')
        .doc(materiaId)
        .collection('actividades')
        .doc(actividadId)
        .update({'estado': nuevoEstado});
    print('✅ Estado actualizado a $nuevoEstado');
  } catch (e) {
    print('❌ Error al cambiar estado de actividad: $e');
    rethrow;
  }
}


  // ✏️ Editar una actividad existente
  Future<void> editarActividad({
    required String materiaId,
    required String actividadId,
    required String titulo,
    required String descripcion,
    required String urgencia,
  }) async {
    try {
      await _db
          .collection('materias')
          .doc(materiaId)
          .collection('actividades')
          .doc(actividadId)
          .update({
        'titulo': titulo,
        'descripcion': descripcion,
        'urgencia': urgencia,
      });
      print('✅ Actividad editada correctamente');
    } catch (e) {
      print('❌ Error al editar actividad: $e');
      rethrow;
    }
  }

  // 🗑️ Eliminar una actividad
  Future<void> eliminarActividad(String materiaId, String actividadId) async {
    try {
      await _db
          .collection('materias')
          .doc(materiaId)
          .collection('actividades')
          .doc(actividadId)
          .delete();
      print('✅ Actividad eliminada correctamente');
    } catch (e) {
      print('❌ Error al eliminar actividad: $e');
      rethrow;
    }
  }

  // 🛡️ Método helper para convertir datos de Firestore de forma segura
  static DateTime? timestampToDateTime(dynamic timestamp) {
    if (timestamp == null) return null;
    
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is DateTime) {
      return timestamp;
    } else {
      print('⚠️ Tipo de timestamp no reconocido: ${timestamp.runtimeType}');
      return null;
    }
  }

  // 📋 Método para obtener datos de actividad de forma segura
  static Map<String, dynamic> procesarDatosActividad(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    return {
      'id': doc.id,
      'titulo': data['titulo'] ?? '',
      'descripcion': data['descripcion'] ?? '',
      'urgencia': data['urgencia'] ?? 'media',
      'notificar': data['notificar'] ?? false,
      'horasNotification': List<String>.from(data['horasNotification'] ?? []),
      'fechaEntrega': timestampToDateTime(data['fechaEntrega']),
      'fechaInicioRango': timestampToDateTime(data['fechaInicioRango']),
      'fechaFinRango': timestampToDateTime(data['fechaFinRango']),
      'createdAt': timestampToDateTime(data['createdAt']),
    };
  }

  // 🔔 Obtener actividades con notificaciones habilitadas
  Stream<List<Map<String, dynamic>>> obtenerActividadesConNotificaciones(String materiaId) {
    return _db
        .collection('materias')
        .doc(materiaId)
        .collection('actividades')
        .where('notificar', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return procesarDatosActividad(doc);
      }).where((actividad) {
        // Filtrar solo actividades con fechas válidas
        return actividad['fechaInicioRango'] != null && 
               actividad['fechaFinRango'] != null &&
               actividad['horasNotification'] != null &&
               (actividad['horasNotification'] as List).isNotEmpty;
      }).toList();
    });
  }
}