import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeLoading()) {
    on<LoadTareasDelDia>(_onLoadTareasDelDia);
  }

  Future<void> _onLoadTareasDelDia(
    LoadTareasDelDia event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      final startOfDay = DateTime(event.fecha.year, event.fecha.month, event.fecha.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await FirebaseFirestore.instance
          .collection('tareas')
          .where('fechaInicio', isGreaterThanOrEqualTo: startOfDay)
          .where('fechaInicio', isLessThan: endOfDay)
          .orderBy('fechaInicio')
          .get();

      if (snapshot.docs.isEmpty) {
        emit(HomeEmpty());
      } else {
        emit(HomeLoaded(tareas: snapshot.docs));
      }
    } catch (e) {
      emit(HomeError(error: e.toString()));
    }
  }
}
