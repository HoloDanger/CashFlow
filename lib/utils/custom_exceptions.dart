/// Exception thrown when a database operation fails.
class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);

  @override
  String toString() => 'DatabaseException: $message';
}

/// Exception thrown when a network operation fails.
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception thrown when a transaction is not found.
class TransactionNotFoundException implements Exception {
  final String message;
  TransactionNotFoundException(this.message);

  @override
  String toString() => 'TransactionNotFoundException: $message';
}
