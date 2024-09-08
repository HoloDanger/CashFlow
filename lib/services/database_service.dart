import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:money_tracker/models/transaction.dart' as my_model;

class DatabaseService {
  // Singleton pattern implementation
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

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
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'cashflow.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE transactions(id TEXT PRIMARY KEY, amount REAL, category TEXT, date TEXT)',
        );
      },
      version: 1,
    );
  }

  // Insert a transaction, replacing if it already exists
  Future<void> insertTransaction(my_model.Transaction transaction) async {
    final db = await _db;
    await db.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve all transaction
  Future<List<my_model.Transaction>> getTransactions() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query('transactions');

    return List.generate(maps.length, (i) {
      return my_model.Transaction.fromMap(maps[i]);
    });
  }

  // Delete a transaction by its ID
  Future<void> deleteTransaction(String id) async {
    final db = await _db;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}
