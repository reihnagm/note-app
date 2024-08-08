import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DB {

  static Future<Database> init() async {
    final dbPath = await sql.getDatabasesPath();
    return await sql.openDatabase(path.join(dbPath, 'notes.db'), onCreate: (db, version) => createDb(db), version: 1);
  } 

  static String tableUsers = 'users';
  static String tableContents = 'contents';
  static String tableNotes = 'notes';
  static String tableNoteContents = 'note_contents';

  static void createDb(Database db) {
    db.execute("CREATE TABLE $tableUsers (id TEXT PRIMARY KEY, username TEXT, password TEXT)");
    db.execute("CREATE TABLE $tableContents (id TEXT PRIMARY KEY, content TEXT, content_json TEXT)");
    db.execute("CREATE TABLE $tableNotes (id TEXT PRIMARY KEY, title TEXT, reminder_date TEXT, pinned TEXT, created_at TEXT, user_id TEXT)");
    db.execute("CREATE TABLE $tableNoteContents (id TEXT PRIMARY KEY, note_id TEXT, content_id TEXT)");
  }

  static Future<List<Map<String, dynamic>>> login({
    required String username, 
    required String password
  }) async {
    final db = await DB.init();

    return db.rawQuery("""
      SELECT id, username, password 
      FROM users 
      WHERE username = '$username' AND password = '$password'
    """);
  }

  static Future<int?> register({
    required String id,
    required String username,
    required String password
  }) async {
    final db = await DB.init();

    return await db.insert(tableUsers, {
      "id": id,
      "username": username,
      "password": password
    }, conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> checkUser({
    required String username
  }) async {
    final db = await DB.init();

    return await db.rawQuery("""
      SELECT username FROM users WHERE username = '$username'
    """);
  } 
 
  static Future<List<Map<String, dynamic>>> getNotes({
    required String title,
    required String userId
  }) async {
    final db = await DB.init();

    return db.rawQuery("""
      SELECT 
        a.reminder_date, 
        a.created_at, 
        a.pinned, 
        a.id AS note_id, 
        GROUP_CONCAT(c.id) AS content_id, 
        a.title AS parent_title, 
        GROUP_CONCAT(c.content) AS content 
      FROM 
        notes a 
        LEFT JOIN note_contents b ON a.id = b.note_id 
        LEFT JOIN contents c ON c.id = b.content_id 
      WHERE 
        a.title LIKE ? AND a.user_id = ? 
      GROUP BY 
        a.id 
      ORDER BY 
        a.pinned DESC, 
        a.created_at DESC
      """, ['%$title%', userId.toString()]
    );
  }

  static Future<List<Map<String, dynamic>>> getNote({
    required String noteId
  }) async {
    final db = await DB.init();

    return db.rawQuery("""
      SELECT a.reminder_date, a.created_at, a.id note_id, c.id content_id, GROUP_CONCAT(a.title) parent_title, c.content, c.content_json 
      FROM notes a 
      LEFT JOIN note_contents b ON a.id = b.note_id 
      LEFT JOIN contents c ON c.id = b.content_id 
      WHERE a.id = '$noteId'
      GROUP BY a.id
    """);
  }

  static Future<int?> storeNote({
    required String id,
    required String title,
    required String reminderDate,
    required String date,
    required String userId
  }) async {
    final db = await DB.init();

    return await db.insert(tableNotes, {
      "id": id,
      "title": title,
      "reminder_date": reminderDate,
      "created_at": date,
      "user_id": userId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  static Future<int?> storeContent({
    required String id,
    required String content,
    required String contentJson,
  }) async {
    final db = await DB.init();

    return await db.insert(tableContents, {
      "id": id,
      "content": content,
      "content_json": contentJson,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  static Future<int?> storeNoteContent({
    required String id,
    required String noteId,
    required String contentId,
  }) async {
    final db = await DB.init();

    return await db.insert(tableNoteContents, {
      "id": id,
      "note_id": noteId,
      "content_id": contentId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  static Future<void> updateNote({
    required String noteId, 
    required String contentId,
    required String title,
    required String content,
    required String contentJson
  }) async {
    final db = await DB.init();
    
    await db.transaction((transaction) async {

      await transaction.update(tableNotes, {
        "title": title,
        "created_at": DateTime.now().toLocal().toString()
      },
        where: 'id = ?',
        whereArgs: [noteId],
      );

      await transaction.update(tableContents, {
          "content": content,
          "content_json": contentJson,
        },
        where: 'id = ?',
        whereArgs: [contentId],
      );
     
    });

  }

  static Future<int?> pinned({
    required String noteId
  }) async {
    final db = await DB.init();

    var result = await db.update(tableNotes, {
      "pinned" : "true",
      "created_at": DateTime.now().toLocal().toString()
    },
      where: 'id = ?',
      whereArgs: [noteId]
    );

    return result;
  }


  static Future<int?> unpinned({
    required String noteId
  }) async {
    final db = await DB.init();

    var result = await db.update(tableNotes, {
      "pinned" : "false",
    },
      where: 'id = ?',
      whereArgs: [noteId]
    );

    return result;
  }

  static Future<void> destoryNote({
    required String noteId,
    required String contentId
  }) async {
    final db = await DB.init();

    await db.transaction((transaction) async {
      await transaction.delete(tableNoteContents,
        where: 'note_id = ? AND content_id = ?',
        whereArgs: [noteId, contentId],
      );

      await transaction.delete(tableNotes,
        where: 'id = ?',
        whereArgs: [noteId],
      );

      await transaction.delete(tableContents,
        where: 'id = ?',
        whereArgs: [contentId],
      );
    });
  }
}