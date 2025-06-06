import 'package:equatable/equatable.dart';

abstract class NubeEvent extends Equatable {
  const NubeEvent();

  @override
  List<Object?> get props => [];
}

class CargarArchivos extends NubeEvent {
  final String materiaId;
  final String filtro;

  const CargarArchivos({required this.materiaId, this.filtro = ''});

  @override
  List<Object?> get props => [materiaId, filtro];
}

class EliminarArchivo extends NubeEvent {
  final String materiaId;
  final String archivoId;

  const EliminarArchivo({required this.materiaId, required this.archivoId});

  @override
  List<Object?> get props => [materiaId, archivoId];
}
