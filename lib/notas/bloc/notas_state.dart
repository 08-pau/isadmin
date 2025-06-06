import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

abstract class NotasState extends Equatable {
  const NotasState();

  @override
  List<Object?> get props => [];
}

class NotasLoading extends NotasState {}

class NotasLoaded extends NotasState {
  final List<QueryDocumentSnapshot> notas;

  const NotasLoaded(this.notas);

  @override
  List<Object?> get props => [notas];
}

class NotasError extends NotasState {
  final String mensaje;

  const NotasError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}
