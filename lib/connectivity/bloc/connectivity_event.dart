abstract class ConnectivityEvent {}

class ConnectivityChanged extends ConnectivityEvent {
  final bool isConnected;
  ConnectivityChanged({required this.isConnected});
}
