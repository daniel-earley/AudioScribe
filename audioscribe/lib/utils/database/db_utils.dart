import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

import 'dart:async';

class DbUtils {
  static const String userDb = 'users';
  static const String bookDb = 'book';
  static const String userBookDb = 'userBook';

  static Future init() async {
    var database = openDatabase(
      path.join(await getDatabasesPath(), 'audioscribe_database.db'),
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE $userDb('
            'id INTEGER PRIMARY KEY,'
            'username TEXT'
          ')'
        );
        db.execute(
          'CREATE TABLE $bookDb('
            'id INTEGER PRIMARY KEY, '
            'title TEXT,'
            'author TEXT,'
            'textFileLocation TEXT,'
            'audioFileLocation TEXT'
          ')'
        );
        db.execute(
          'CREATE TABLE $userBookDb('
            'id INTEGER PRIMARY KEY, '
            'userId INTEGER NOT NULL, '
            'bookId INTEGER NOT NULL, '
            'FOREIGN KEY (userId) REFERENCES $userDb(id) ON DELETE CASCADE'
            'FOREIGN KEY (bookId) REFERENCES $bookDb(id) ON DELETE CASCADE'
          ')'
        );
      },
      version: 1,
    );

    return database;
  }
}