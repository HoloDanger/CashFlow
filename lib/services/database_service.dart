import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:money_tracker/models/transaction.dart' as my_model;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService(path) {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

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

  Future<void> insertTransaction(my_model.Transaction transaction) async {
    final db = await database;
    await db.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<my_model.Transaction>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transactions');
    return List.generate(maps.length, (i) {
      return my_model.Transaction.fromMap(maps[i]);
    });
  }
}
