import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:synchronized/synchronized.dart';
import 'package:to_do/models/user.dart';

import '../models/task.dart';

class TodoDatabase {
  static final TodoDatabase _todoDatabase = TodoDatabase._internal();
  bool didInit = false;
  Directory documentsDirectory;
  String path;
  Database db;
  String userTABLE = "User";
  String toDoTABLE = "Todo_List";

  static TodoDatabase get() => _todoDatabase;

  final _lock = Lock();

  TodoDatabase._internal();

  Future<Database> _getDb() async {
    if (!didInit) await _init();
    return db;
  }

  Future _init() async {
    documentsDirectory = await getApplicationDocumentsDirectory();
    path = join(documentsDirectory.path, "todo.db");
    await _lock.synchronized(() async {
      db = await openDatabase(path, version: 1, onCreate: _onCreate);
    });
    didInit = true;
  }

  _onCreate(Database db, int version) async {
    await db.execute('CREATE TABLE $toDoTABLE ('
        '${TodoModel.dbTodoTitle} TEXT,'
        '${TodoModel.dbTime} TEXT,'
        '${TodoModel.dbIsCompleted} TEXT'
        ')');
    await db.execute('CREATE TABLE $userTABLE ('
        '${UserModel.dbName} TEXT,'
        '${UserModel.dbEmail} TEXT'
        ')');
  }

  //returns non zero integer
  Future<int> addTodo(
    TodoModel todo,
  ) async {
    var db = await _getDb();
    return Future.value(await db.insert(toDoTABLE, todo.toJson()));
  }

  //returns non zero integer
  Future<int> addUser(
    UserModel user,
  ) async {
    var db = await _getDb();
    return Future.value(await db.insert(userTABLE, user.toJson()));
  }

  Future<UserModel> getUser() async {
    var db = await _getDb();
    List result = await db.query(userTABLE);
    return result.isNotEmpty ? UserModel.fromJson(result[0]) : null;
  }

  Future<List<TodoModel>> getTodo() async {
    var db = await _getDb();
    var result = await db.query(toDoTABLE);
    List<TodoModel> chats = [];
    for (int i = 0; i < result.length; i++) {
      chats.add(TodoModel.fromJson(result[i]));
    }
    return chats;
  }

  //returns 1 if updated
  Future<int> updateTodo(TodoModel todo) async {
    var db = await _getDb();
    return Future.value(await db.update(toDoTABLE, todo.toJson(),
        where: '${TodoModel.dbTime}=?',
        whereArgs: [todo.time.toIso8601String()]));
  }

  //returns 1 if deleted
  Future<int> deleteTodo(
    TodoModel todo,
  ) async {
    var db = await _getDb();
    return Future.value(await db.delete(toDoTABLE,
        where: '${TodoModel.dbTodoTitle}=?', whereArgs: [todo.todoTitle]));
  }

  //returns 1 if deleted
  Future<int> deleteUser(
    TodoModel todo,
  ) async {
    var db = await _getDb();
    return Future.value(await db.delete(userTABLE));
  }

  Future truncateAllTable() async {
    var db = await _getDb();
    await db.transaction((txn) async {
      await txn.delete(toDoTABLE);
      await txn.delete(userTABLE);
    });
  }
}
