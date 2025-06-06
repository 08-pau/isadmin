import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ActividadesState {}

class ActividadesInitial extends ActividadesState {}

class ActividadesLoading extends ActividadesState {}

class ActividadesCargadas extends ActividadesState {
  final List<QueryDocumentSnapshot> actividades;
  ActividadesCargadas(this.actividades);
}

class ActividadesError extends ActividadesState {
  final String mensaje;
  ActividadesError(this.mensaje);
}
