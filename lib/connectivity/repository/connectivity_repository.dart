import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityRepository {
  final Connectivity _connectivity = Connectivity();

  Future<bool> hasConnection() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Stream<bool> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.map((result) {
        return result != ConnectivityResult.none;
      });
}
