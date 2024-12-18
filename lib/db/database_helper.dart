import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    return await openDatabase(
      join(dbPath, 'bills.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE bills (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            customerName TEXT,
            contactNumber TEXT,
            totalAmount REAL,
            status TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            billId INTEGER,
            itemName TEXT,
            quantity INTEGER,
            unitPrice REAL,
            FOREIGN KEY (billId) REFERENCES bills (id)
          )
        ''');
      },
      version: 1,
    );
  }

  Future<int> insertBill(Map<String, dynamic> bill) async {
    final db = await database;
    return await db.insert('bills', bill);
  }

  Future<List<Map<String, dynamic>>> getBills() async {
    final db = await database;
    return await db.query('bills');
  }

  Future<int> insertItem(Map<String, dynamic> item) async {
    final db = await database;
    return await db.insert('items', item);
  }

  Future<List<Map<String, dynamic>>> getItemsByBillId(int billId) async {
    final db = await database;
    return await db.query(
      'items',
      where: 'billId = ?',
      whereArgs: [billId],
    );
  }
  // Future<int> updateBill(Map<String, dynamic> bill) async {
  //   final db = await database;
  //   return await db.update(
  //     'bills',
  //     bill,
  //     where: 'id = ?',
  //     whereArgs: [bill['id']],
  //   );
  // }

  Future<int> updateBill(Map<String, dynamic> bill) async {
    final db = await database;
    return await db.update(
      'bills', // Your table name
      bill,
      where: 'id = ?',
      whereArgs: [bill['id']],
    );
  }


}
