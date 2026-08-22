import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AleraDatabase {
  AleraDatabase._();

  static final AleraDatabase instance =
      AleraDatabase._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initializeDatabase();

    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    final String databasePath =
        await getDatabasesPath();

    final String path = join(
      databasePath,
      'alera_local.db',
    );

    return openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(
    Database db,
    int version,
  ) async {
     await db.execute(
    '''
    CREATE TABLE upload_queue (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      metric_type TEXT NOT NULL,
      payload_json TEXT NOT NULL,
      created_at TEXT NOT NULL,
      retry_count INTEGER NOT NULL DEFAULT 0,
      queue_status TEXT NOT NULL DEFAULT 'PENDING',
      last_error TEXT
      )
    ''',
    );
  }
}