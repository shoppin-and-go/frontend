class CartNotFoundException implements Exception {
  final String message;
  CartNotFoundException(this.message);
}

class DeviceAlreadyConnectedException implements Exception {
  final String message;
  DeviceAlreadyConnectedException(this.message);
}

class UnconnectedCartException implements Exception {
  final String message;
  UnconnectedCartException(this.message);
}
