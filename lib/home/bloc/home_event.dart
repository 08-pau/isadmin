part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTareasDelDia extends HomeEvent {
  final DateTime fecha;

  LoadTareasDelDia({required this.fecha});

  @override
  List<Object?> get props => [fecha];
}
