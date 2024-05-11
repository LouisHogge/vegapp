import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// A helper class for managing the SQLite database.
class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _db;
  static const int _version = 1;
  static const String _dbName = "local.db";

  DatabaseHelper._privateConstructor();

  /// Returns the singleton instance of the [DatabaseHelper].
  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._privateConstructor();
    return _instance!;
  }

  /// Retrieves the database instance. If the database is not yet initialized, it will be initialized first.
  Future<Database> getDatabase() async {
    if (_db != null) return _db!;
    _db = await initDatabase();
    return _db!;
  }

  /// Closes the database connection.
  Future<void> closeDatabase() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }

  /// Deletes the database file.
  static Future<void> deleteDatabaseFile() async {
    String dbPath = join(await getDatabasesPath(), _dbName);

    // Ensure the database is closed before deleting its file
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }

    final file = File(dbPath);
    if (await file.exists()) {
      try {
        await file.delete();
      } catch (e) {
        rethrow;
      }
    }
  }

  /// Initializes the database by creating the necessary tables.
  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), _dbName);
    Database db;
    try {
      db = await openDatabase(path,
          version: _version, onCreate: _onCreate, onUpgrade: _onUpgrade);
    } catch (e) {
      rethrow;
    }
    return db;
  }

  /// Callback function for creating the database tables.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
        CREATE TABLE garden (
          id INTEGER PRIMARY KEY ,
          name VARCHAR(255) UNIQUE
        )
      ''');

    await db.execute('''
        CREATE TABLE category_primary (
          id INTEGER PRIMARY KEY ,
          name VARCHAR(255) NOT NULL,
          garden_id INTEGER NOT NULL,
          FOREIGN KEY (garden_id) REFERENCES garden(id)
        )
      ''');

    await db.execute('''
        CREATE TABLE category_secondary (
          id INTEGER PRIMARY KEY ,
          name VARCHAR(255) NOT NULL,
          color VARCHAR(50) NOT NULL,
          garden_id INTEGER NOT NULL,
          FOREIGN KEY (garden_id) REFERENCES garden(id)
        )
      ''');

    await db.execute('''
        CREATE TABLE vegetable (
          id INTEGER PRIMARY KEY ,
          name VARCHAR(255),
          seed_availability INT,
          seed_expiration INT,
          harvest_start INT,
          harvest_end INT,
          plant_start VARCHAR(255),
          plant_end VARCHAR(255),
          note VARCHAR(255),
          category_primary_id INTEGER REFERENCES category_primary(id),
          category_secondary_id INTEGER REFERENCES category_secondary(id),
          garden_id INTEGER REFERENCES garden(id)
        )
      ''');

    await db.execute('''
        CREATE TABLE plot (
          id INTEGER PRIMARY KEY ,
          name VARCHAR(255),
          creation_date DATE,
          in_calendar INT,
          nb_of_lines VARCHAR(255),
          orientation INT,
          version INT,
          note VARCHAR(255),
          garden_id INT NOT NULL,
          FOREIGN KEY (garden_id) REFERENCES garden(id)
        )
      ''');

    await db.execute('''
        CREATE TABLE planted (
          id INTEGER PRIMARY KEY,
          plot_id INT NOT NULL,
          veggie_id INT NOT NULL,
          vegetable_location VARCHAR(255)
        )
      ''');

    await db.execute('''
        CREATE TABLE calendar (
          id INTEGER PRIMARY KEY ,
          garden_id INT NOT NULL,
          harvest_done INT,
          note VARCHAR(255),
          plant_done INT,
          veggie_id INT NOT NULL
        )
      ''');

    await db.execute('''
        CREATE TABLE sync (
          id INTEGER PRIMARY KEY ,
          api_number INT,
          api_url VARCHAR(255),
          api_body VARCHAR(255),
          api_type INT
        )
      ''');
  }

  /// Callback function for upgrading the database.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      // Perform database upgrade logic
    }
  }
}
