class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class TransactionNotFoundException implements Exception {
  final String message;
  TransactionNotFoundException(this.message);
}
