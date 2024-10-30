import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:money_tracker/services/database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Initialize sqlite_common_ffi for desktop testing
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Database Migration Tests', () {
    late DatabaseService databaseService;
    late String testDbPath;

    setUpAll(() async {
      databaseService = DatabaseService();
      final dbPath = await getDatabasesPath();
      testDbPath = join(dbPath, 'test_cashflow.db');
    });

    setUp(() async {
      await deleteDatabase(testDbPath);
    });

    tearDown(() async {
      await deleteDatabase(testDbPath);
    });

    test('Database migration from version 1 to 2', () async {
      // Step 1: Create a test database with the old schema (version 1)
      final db = await openDatabase(
        testDbPath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE transactions(id TEXT PRIMARY KEY, amount REAL, category TEXT, date TEXT)',
          );
        },
      );

      // Verify the old schema
      final oldSchema = await db.rawQuery('PRAGMA table_info(transactions)');
      expect(oldSchema.length, 4); // id, amount, category, date
      expect(oldSchema.any((column) => column['name'] == 'notes'), isFalse);

      await db.close();

      // Step 2: Open the database with the new version (version 2)
      final upgradedDb = await openDatabase(
        testDbPath,
        version: 2,
        onUpgrade: (db, oldVersion, newVersion) async {
          await databaseService.migrate(db, oldVersion, newVersion);
        },
      );

      // Verify the new schema
      final newSchema =
          await upgradedDb.rawQuery('PRAGMA table_info(transactions)');
      expect(newSchema.length, 5); // id, amount, category, date, notes
      expect(newSchema.any((column) => column['name'] == 'notes'), isTrue);

      await upgradedDb.close();
    });
  });
}
