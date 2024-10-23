import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:money_tracker/models/transaction.dart' as my_model;

class DatabaseService {
  // Singleton pattern implementation
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  final Logger _logger = Logger();

  // Factory constructor ensures a single instance
  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  // Getter for the database, initializing it if necessary
  Future<Database> get _db async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDB() async {
    try {
      final dbPath = await getDatabasesPath();
      _logger.i('Initializing database at path: $dbPath');
      return await openDatabase(
        join(dbPath, 'cashflow.db'),
        onCreate: (db, version) {
          _logger.i('Creating table at version $version');
          return db.execute(
            'CREATE TABLE transactions(id TEXT PRIMARY KEY, amount REAL, category TEXT, date TEXT)',
          );
        },
        version: 1,
      );
    } catch (e) {
      _logger.e('Error during database initialization: $e');
      rethrow;
    }
  }

  // Retrieve all transaction
  Future<List<my_model.Transaction>> getTransactions(
      {int limit = 20, int offset = 0}) async {
    final db = await _db;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'transactions',
        limit: limit,
        offset: offset,
        orderBy: 'date DESC',
      );
      return maps.map((map) => my_model.Transaction.fromMap(map)).toList();
    } catch (e) {
      _logger.e('Failed to fetch transactions: $e');
      rethrow;
    }
  }

  // Insert or replace a transaction
  Future<void> insertTransaction(my_model.Transaction transaction) async {
    final db = await _db;
    try {
      await db.insert(
        'transactions',
        transaction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      _logger.e('Failed to insert transaction: $e');
      rethrow;
    }
  }

  // Delete a transaction by its ID
  Future<int> deleteTransaction(String id) async {
    final db = await _db;
    try {
      return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      _logger.e('Failed to delete transaction: $e');
      rethrow;
    }
  }

  // Close the database
  Future<void> closeDB() async {
    final db = await _db;
    try {
      await db.close();
    } catch (e) {
      _logger.e('Failed to close database: $e');
      rethrow;
    }
  }
}
