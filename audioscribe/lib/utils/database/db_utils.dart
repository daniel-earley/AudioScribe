import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

import 'dart:async';

class DbUtils {
  static const String userDb = 'users';
  static const String bookDb = 'book';
  static const String userBookDb = 'userBook';

  static Future<Database> init() async {
    var database = openDatabase(
      path.join(await getDatabasesPath(), 'audioscribe_database.db'),
      onCreate: (Database db, version) {
        db.execute(
          'CREATE TABLE $userDb('
            'id TEXT PRIMARY KEY,'
            'username TEXT, '
            'loggedIn INTEGER'
          ')'
        );
        db.execute(
          'CREATE TABLE $bookDb('
            'id INTEGER PRIMARY KEY, '
            'title TEXT,'
            'author TEXT,'
            'textFileLocation TEXT, '
            'audioFileLocation TEXT, '
            'imageFileLocation TEXT'
          ')'
        );
        db.execute(
          'CREATE TABLE $userBookDb('
            'id INTEGER PRIMARY KEY, '
            'userId TEXT NOT NULL, '
            'bookId INTEGER NOT NULL, '
            'FOREIGN KEY (userId) REFERENCES $userDb(id) ON DELETE CASCADE '
            'FOREIGN KEY (bookId) REFERENCES $bookDb(id) ON DELETE CASCADE'
          ')'
        );
      },
      version: 1,
    );

    return database;
  }
}