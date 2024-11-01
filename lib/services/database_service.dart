import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:money_tracker/models/transaction.dart' as my_model;
import 'package:money_tracker/utils/custom_exceptions.dart' as my_exceptions;

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

  // Initialize the database with versioning
  Future<Database> _initDB() async {
    try {
      final dbPath = await getDatabasesPath();
      _logger.i('Initializing database');
      return await openDatabase(
        join(dbPath, 'cashflow.db'),
        onCreate: (db, version) {
          _logger.i('Creating table at version $version');
          return db.execute(
            '''CREATE TABLE transactions(
              id TEXT PRIMARY KEY, 
              amount REAL, 
              category TEXT, 
              date TEXT,
              formattedDate TEXT,
              isRecurring INTEGER,
              recurrenceFrequency TEXT,
              nextOccurrence TEXT
            )
            ''',
          );
        },
        onUpgrade: (db, oldVersion, newVersion) {
          _logger
              .i('Upgrading database from version $oldVersion to $newVersion');
          migrate(db, oldVersion, newVersion);
        },
        version: 3,
      );
    } catch (e) {
      _logger.e('Error during database initialization: $e');
      rethrow;
    }
  }

  // Migration logic
  Future<void> migrate(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE transactions ADD COLUMN notes TEXT');
      _logger
          .i('Migrated to version 2: Added notes column to transactions table');
    }
    if (oldVersion < 3) {
      final existingColumns =
          await db.rawQuery('PRAGMA table_info(transactions)');
      final columnNames =
          existingColumns.map((col) => col['name'] as String).toList();

      if (!columnNames.contains('formattedDate')) {
        await db
            .execute('ALTER TABLE transactions ADD COLUMN formattedDate TEXT');
      }
      if (!columnNames.contains('formattedAmount')) {
        await db.execute(
            'ALTER TABLE transactions ADD COLUMN formattedAmount TEXT');
      }
      if (!columnNames.contains('isRecurring')) {
        await db
            .execute('ALTER TABLE transactions ADD COLUMN isRecurring INTEGER');
      }
      if (!columnNames.contains('recurrenceFrequency')) {
        await db.execute(
            'ALTER TABLE transactions ADD COLUMN recurrenceFrequency TEXT');
      }
      if (!columnNames.contains('nextOccurrence')) {
        await db
            .execute('ALTER TABLE transactions ADD COLUMN nextOccurrence TEXT');
      }

      _logger.i(
          'Migrated to version 3: Added multiple columns to transactions table');
    }
  }

  void _handleDatabaseError(String message, Object error) {
    _logger.e('$message: $error');
    throw my_exceptions.DatabaseException(message);
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
      _handleDatabaseError('Failed to fetch transactions', e);
      return [];
    }
  }

  // Insert or replace a transaction within a transaction
  Future<void> insertTransaction(my_model.Transaction transaction) async {
    final db = await _db;
    await db.transaction((txn) async {
      try {
        await txn.insert(
          'transactions',
          transaction.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } catch (e) {
        _logger.e('Failed to insert transaction: $e');
        throw my_exceptions.DatabaseException('Failed to insert transaction');
      }
    });
  }

  // Update an existing transaction
  Future<void> updateTransaction(my_model.Transaction transaction) async {
    final db = await _db;
    await db.transaction((txn) async {
      try {
        await txn.update(
          'transactions',
          transaction.toMap(),
          where: 'id = ?',
          whereArgs: [transaction.id],
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        _logger.i('Updated transaction: ${transaction.id}');
      } catch (e) {
        _handleDatabaseError('Failed to insert transaction', e);
      }
    });
  }

  // Delete a transaction by its ID
  Future<int> deleteTransaction(String id) async {
    final db = await _db;
    return await db.transaction((txn) async {
      try {
        return await txn
            .delete('transactions', where: 'id = ?', whereArgs: [id]);
      } catch (e) {
        _logger.e('Failed to delete transaction: $e');
        throw my_exceptions.DatabaseException('Failed to delete transaction');
      }
    });
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
