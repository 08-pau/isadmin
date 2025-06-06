
import 'package:cloud_firestore/cloud_firestore.dart';

class CursoRepository {
  Future<double> calcularProgreso(String materiaId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('materias')
        .doc(materiaId)
        .collection('calificaciones')
        .get();

    double total = 0;
    double logrado = 0;

    for (var doc in snapshot.docs) {
      final obtenido = (doc['porcentaje obtenido'] as num).toDouble();
      final totalItem = (doc['porcentaje total'] as num).toDouble();
      total += totalItem;
      logrado += obtenido;
    }

    if (total == 0) return 0;
    return logrado / total;
  }
}