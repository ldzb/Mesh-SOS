import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/sos_message.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'mesh_sos.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE sos_messages(id INTEGER PRIMARY KEY AUTOINCREMENT, senderId TEXT, latitude REAL, longitude REAL, message TEXT, timestamp TEXT, isSynced INTEGER DEFAULT 0)",
        );
      },
    );
  }

  Future<void> insertMessage(SosMessage message) async {
    final db = await database;
    await db.insert('sos_messages', message.toMap());
  }

  Future<List<SosMessage>> getUnsyncedMessages() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('sos_messages', where: 'isSynced = 0');
    return List.generate(maps.length, (i) => SosMessage.fromMap(maps[i]));
  }

  Future<void> markAsSynced(List<String?> ids) async {
    final db = await database;
    // Note: In MVP, simplified by marking all as synced for now
    await db.update('sos_messages', {'isSynced': 1}, where: 'isSynced = 0');
  }
}
