part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<QueryDocumentSnapshot> tareas;

  HomeLoaded({required this.tareas});

  @override
  List<Object?> get props => [tareas];
}

class HomeEmpty extends HomeState {}

class HomeError extends HomeState {
  final String error;

  HomeError({required this.error});

  @override
  List<Object?> get props => [error];
}
