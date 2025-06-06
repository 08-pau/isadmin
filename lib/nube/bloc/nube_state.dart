import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

abstract class NubeState extends Equatable {
  const NubeState();

  @override
  List<Object?> get props => [];
}

class NubeInitial extends NubeState {}

class NubeLoading extends NubeState {}

class NubeLoaded extends NubeState {
  final List<QueryDocumentSnapshot> archivos;

  const NubeLoaded(this.archivos);

  @override
  List<Object?> get props => [archivos];
}

class NubeEmpty extends NubeState {}

class NubeError extends NubeState {
  final String message;

  const NubeError(this.message);

  @override
  List<Object?> get props => [message];
}
