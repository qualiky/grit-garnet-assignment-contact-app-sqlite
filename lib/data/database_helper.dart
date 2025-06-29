import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'contact_model.dart';

class DatabaseHelper {
  static const _databaseName = "Contacts.db";
  static const _databaseVersion = 1;

  static const table = 'contacts';

  static const columnId = 'id';
  static const columnName = 'name';
  static const columnPhone = 'phone';
  static const columnEmail = 'email';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnName TEXT NOT NULL,
            $columnPhone TEXT NOT NULL,
            $columnEmail TEXT NOT NULL
          )
          ''');
  }


  Future<int> insert(Contact contact) async {
    Database db = await instance.database;
    return await db.insert(table, contact.toMap());
  }

  Future<List<Contact>> getAllContacts() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(table, orderBy: "$columnName ASC");

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(maps.length, (i) {
      return Contact.fromMap(maps[i]);
    });
  }

  Future<int> update(Contact contact) async {
    Database db = await instance.database;
    int id = contact.id!;
    return await db.update(table, contact.toMap(), where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}