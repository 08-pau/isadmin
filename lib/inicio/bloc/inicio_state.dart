import 'package:equatable/equatable.dart';

abstract class InicioState extends Equatable {
  @override
  List<Object?> get props => [];
}

class InicioInitial extends InicioState {}

class InicioReady extends InicioState {}
