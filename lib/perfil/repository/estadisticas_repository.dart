import 'package:cloud_firestore/cloud_firestore.dart';

class EstadisticasRepository {
  final _notasRef = FirebaseFirestore.instance.collection('notas');
  final _materiasRef = FirebaseFirestore.instance.collection('materias');
  final _tareasRef = FirebaseFirestore.instance.collection('tareas');
  final _usuariosRef = FirebaseFirestore.instance.collection('usuarios');

  // Obtener estadísticas completas del usuario
  Future<Map<String, int>> obtenerEstadisticas(String userId) async {
    try {
      // Ejecutar todas las consultas en paralelo para mejor rendimiento
      final results = await Future.wait([
        _obtenerCantidadNotas(userId),
        _obtenerCantidadMaterias(userId), 
        _obtenerCantidadTareas(userId),
        _obtenerDiasActivo(userId),
      ]);

      return {
        'notas': results[0],
        'materias': results[1],
        'tareas': results[2],
        'diasActivo': results[3],
      };
    } catch (e) {
      print('Error obteniendo estadísticas: $e');
      // En caso de error, devolver valores por defecto
      return {
        'notas': 0,
        'materias': 0,
        'tareas': 0,
        'diasActivo': 0,
      };
    }
  }

  // Obtener cantidad de notas - Intenta con filtro de usuario, si falla usa método global
  Future<int> _obtenerCantidadNotas(String userId) async {
    try {
      // Primero intenta filtrar por usuario
      var snapshot = await _notasRef
          .where('userId', isEqualTo: userId)
          .get();
      
      // Si no encuentra nada, verifica si es porque el campo tiene otro nombre
      if (snapshot.docs.isEmpty) {
        // Intenta con otros posibles nombres de campo
        final alternativeFields = ['uid', 'user_id', 'autorId', 'createdBy'];
        
        for (String field in alternativeFields) {
          try {
            snapshot = await _notasRef
                .where(field, isEqualTo: userId)
                .get();
            
            if (snapshot.docs.isNotEmpty) {
              print('Notas encontradas usando campo: $field');
              return snapshot.docs.length;
            }
          } catch (e) {
            // Continúa con el siguiente campo
            continue;
          }
        }
        
        // Si aún no encuentra nada, usa el método global como respaldo
        print('No se encontraron notas filtradas, usando método global');
        return await _obtenerCantidadNotasGlobal();
      }
      
      return snapshot.docs.length;
    } catch (e) {
      print('Error obteniendo notas: $e');
      // Como último recurso, usar método global
      return await _obtenerCantidadNotasGlobal();
    }
  }

  // Método global de respaldo para notas
  Future<int> _obtenerCantidadNotasGlobal() async {
    try {
      final snapshot = await _notasRef.get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error en método global de notas: $e');
      return 0;
    }
  }

  // Obtener cantidad de materias - Con mismo enfoque híbrido
  Future<int> _obtenerCantidadMaterias(String userId) async {
    try {
      // Primero intenta filtrar por usuario
      var snapshot = await _materiasRef
          .where('userId', isEqualTo: userId)
          .get();
      
      // Si no encuentra nada, verifica otros campos posibles
      if (snapshot.docs.isEmpty) {
        final alternativeFields = ['uid', 'user_id', 'autorId', 'createdBy'];
        
        for (String field in alternativeFields) {
          try {
            snapshot = await _materiasRef
                .where(field, isEqualTo: userId)
                .get();
            
            if (snapshot.docs.isNotEmpty) {
              print('Materias encontradas usando campo: $field');
              return snapshot.docs.length;
            }
          } catch (e) {
            continue;
          }
        }
        
        // Respaldo global
        print('No se encontraron materias filtradas, usando método global');
        return await _obtenerCantidadMateriasGlobal();
      }
      
      return snapshot.docs.length;
    } catch (e) {
      print('Error obteniendo materias: $e');
      return await _obtenerCantidadMateriasGlobal();
    }
  }

  // Método global de respaldo para materias
  Future<int> _obtenerCantidadMateriasGlobal() async {
    try {
      final snapshot = await _materiasRef.get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error en método global de materias: $e');
      return 0;
    }
  }

  // Obtener cantidad de tareas - Con mismo enfoque híbrido
  Future<int> _obtenerCantidadTareas(String userId) async {
    try {
      // Primero intenta filtrar por usuario
      var snapshot = await _tareasRef
          .where('userId', isEqualTo: userId)
          .get();
      
      // Si no encuentra nada, verifica otros campos posibles
      if (snapshot.docs.isEmpty) {
        final alternativeFields = ['uid', 'user_id', 'autorId', 'createdBy'];
        
        for (String field in alternativeFields) {
          try {
            snapshot = await _tareasRef
                .where(field, isEqualTo: userId)
                .get();
            
            if (snapshot.docs.isNotEmpty) {
              print('Tareas encontradas usando campo: $field');
              return snapshot.docs.length;
            }
          } catch (e) {
            continue;
          }
        }
        
        // Respaldo global
        print('No se encontraron tareas filtradas, usando método global');
        return await _obtenerCantidadTareasGlobal();
      }
      
      return snapshot.docs.length;
    } catch (e) {
      print('Error obteniendo tareas: $e');
      return await _obtenerCantidadTareasGlobal();
    }
  }

  // Método global de respaldo para tareas
  Future<int> _obtenerCantidadTareasGlobal() async {
    try {
      final snapshot = await _tareasRef.get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error en método global de tareas: $e');
      return 0;
    }
  }

  // Registrar actividad diaria del usuario (del código nuevo)
  Future<void> registrarActividadDiaria(String userId) async {
    try {
      final now = DateTime.now();
      final hoy = DateTime(now.year, now.month, now.day);
      final fechaString = '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';
      
      final actividadRef = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .collection('actividad')
          .doc(fechaString);
      
      final doc = await actividadRef.get();
      if (!doc.exists) {
        await actividadRef.set({
          'fecha': Timestamp.fromDate(hoy),
          'activo': true,
          'ultimaActividad': FieldValue.serverTimestamp(),
        });
      } else {
        await actividadRef.update({
          'ultimaActividad': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error registrando actividad: $e');
    }
  }

  // Calcular días activos (del código nuevo, que funciona bien)
  Future<int> _obtenerDiasActivo(String userId) async {
    try {
      // Contar documentos en la subcolección de actividad
      final actividadSnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .collection('actividad')
          .get();
      
      return actividadSnapshot.docs.length;
    } catch (e) {
      print('Error obteniendo días activos: $e');
      // Si falla, usar el método anterior como respaldo
      return await _obtenerDiasActivoRespaldo(userId);
    }
  }

  // Método de respaldo para calcular días desde registro (del código anterior)
  Future<int> _obtenerDiasActivoRespaldo(String userId) async {
    try {
      final userDoc = await _usuariosRef.doc(userId).get();
      if (!userDoc.exists) return 0;

      final data = userDoc.data() as Map<String, dynamic>;
      final createAt = data['CreateAt'];
      
      if (createAt == null) return 0;

      DateTime fechaRegistro;
      if (createAt is Timestamp) {
        fechaRegistro = createAt.toDate();
      } else if (createAt is DateTime) {
        fechaRegistro = createAt;
      } else {
        fechaRegistro = DateTime.tryParse(createAt.toString()) ?? DateTime.now();
      }

      final ahora = DateTime.now();
      final diferencia = ahora.difference(fechaRegistro).inDays;
      
      return diferencia >= 0 ? diferencia : 0;
    } catch (e) {
      print('Error en respaldo días activos: $e');
      return 0;
    }
  }

  // Obtener estadísticas específicas de tareas por usuario
  Future<Map<String, int>> obtenerEstadisticasTareas(String userId) async {
    try {
      // Intenta con filtro de usuario primero
      Query baseQuery = _tareasRef.where('userId', isEqualTo: userId);
      
      var results = await Future.wait([
        baseQuery.where('estado', isEqualTo: 'pendiente').get(),
        baseQuery.where('estado', isEqualTo: 'completada').get(),
        baseQuery.where('estado', isEqualTo: 'en_proceso').get(),
      ]);

      var pendientes = results[0].docs.length;
      var completadas = results[1].docs.length;
      var enProceso = results[2].docs.length;

      // Si no encuentra tareas, intenta métodos alternativos
      if (pendientes + completadas + enProceso == 0) {
        // Método global como respaldo
        results = await Future.wait([
          _tareasRef.where('estado', isEqualTo: 'pendiente').get(),
          _tareasRef.where('estado', isEqualTo: 'completada').get(),
          _tareasRef.where('estado', isEqualTo: 'en_proceso').get(),
        ]);

        pendientes = results[0].docs.length;
        completadas = results[1].docs.length;
        enProceso = results[2].docs.length;
      }

      return {
        'pendientes': pendientes,
        'completadas': completadas,
        'enProceso': enProceso,
        'total': pendientes + completadas + enProceso,
      };
    } catch (e) {
      print('Error obteniendo estadísticas de tareas: $e');
      return {
        'pendientes': 0,
        'completadas': 0,
        'enProceso': 0,
        'total': 0,
      };
    }
  }

  // Método para verificar qué campos de usuario existen en las colecciones
  Future<void> verificarCamposUsuario() async {
    try {
      print('=== VERIFICANDO CAMPOS DE USUARIO ===');
      
      // Verificar notas
      final notasSnapshot = await _notasRef.limit(5).get();
      if (notasSnapshot.docs.isNotEmpty) {
        print('Campos en notas: ${notasSnapshot.docs.first.data().keys.toList()}');
      }
      
      // Verificar materias
      final materiasSnapshot = await _materiasRef.limit(5).get();
      if (materiasSnapshot.docs.isNotEmpty) {
        print('Campos en materias: ${materiasSnapshot.docs.first.data().keys.toList()}');
      }
      
      // Verificar tareas
      final tareasSnapshot = await _tareasRef.limit(5).get();
      if (tareasSnapshot.docs.isNotEmpty) {
        print('Campos en tareas: ${tareasSnapshot.docs.first.data().keys.toList()}');
      }
      
      print('=== FIN VERIFICACIÓN ===');
    } catch (e) {
      print('Error verificando campos: $e');
    }
  }
}