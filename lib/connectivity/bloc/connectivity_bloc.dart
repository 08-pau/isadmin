import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../repository/connectivity_repository.dart';
import 'connectivity_event.dart';
import 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final ConnectivityRepository repository;
  late final StreamSubscription _subscription;

  ConnectivityBloc({required this.repository}) : super(ConnectivityInitial()) {
    _subscription = repository.onConnectivityChanged.listen((result) {
      add(ConnectivityChanged(isConnected: result));
    });

    on<ConnectivityChanged>((event, emit) {
      if (event.isConnected) {
        emit(ConnectivityOnline());
      } else {
        emit(ConnectivityOffline());
      }
    });

    _init();
  }

  Future<void> _init() async {
    final isConnected = await repository.hasConnection();
    add(ConnectivityChanged(isConnected: isConnected));
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
