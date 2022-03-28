@TestOn('vm')
library sqflite_common_ffi.test.sqflite_ffi_doc_test;

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:to_do/models/task.dart';
import 'package:to_do/models/user.dart';
import 'package:to_do/utils/text_validator.dart';

Future<void> main() async {
  sqfliteFfiInit();
  String toDoTABLE = "Todo_List";
  String userTABLE = "User";

  TodoModel taskOne =
      TodoModel(todoTitle: 'Sample task_one', time: DateTime.now());
  UserModel user = UserModel('Krishnamoorthy', email: 'krishna@gmail.com');
  var factory = databaseFactoryFfi;

  OpenDatabaseOptions getOpenDbForTodo() => OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE $toDoTABLE ('
            '${TodoModel.dbTodoTitle} TEXT,'
            '${TodoModel.dbTime} TEXT,'
            '${TodoModel.dbIsCompleted} TEXT'
            ')');
        await db.execute('CREATE TABLE $userTABLE ('
            '${UserModel.dbName} TEXT,'
            '${UserModel.dbEmail} TEXT'
            ')');
      });
  test('Insert User', () async {
    var db = await factory.openDatabase(inMemoryDatabasePath,
        options: getOpenDbForTodo());
    var result = await db.insert(userTABLE, user.toJson());
    expect(result, 1);
    await db.close();
  });
  test('User input validation', () async {
    var emptyCheck = TodoValidator().validateUserName('');
    expect(emptyCheck, TodoConstants.userNameMandatory);
    var nullCheck = TodoValidator().validateUserName(null);
    expect(nullCheck, TodoConstants.userNameMandatory);
    var nonEmptyString = TodoValidator().validateUserName('Krishnamoorthy');
    expect(nonEmptyString, null);
  });

  test('Get todo initially list', () async {
    var db = await factory.openDatabase(inMemoryDatabasePath,
        options: getOpenDbForTodo());
    var result = await db.query(toDoTABLE);
    expect(result, []);
    await db.close();
  });
  test('Get todo list', () async {
    var db = await factory.openDatabase(inMemoryDatabasePath,
        options: getOpenDbForTodo());
    await db.insert(toDoTABLE, taskOne.toJson());
    var result = await db.query(toDoTABLE);
    expect(result, [taskOne.toJson()]);
    await db.close();
  });
  test('Insert todo', () async {
    var db = await factory.openDatabase(inMemoryDatabasePath,
        options: getOpenDbForTodo());
    var result = await db.insert(toDoTABLE, taskOne.toJson());
    expect(result, 1);
    await db.close();
  });

  test('Update todo', () async {
    var db = await factory.openDatabase(inMemoryDatabasePath,
        options: getOpenDbForTodo());
    await db.insert(toDoTABLE, taskOne.toJson());
    var result = await db.update(toDoTABLE, taskOne.toJson(),
        where: '${TodoModel.dbTime}=?',
        whereArgs: [taskOne.time.toIso8601String()]);
    expect(result, 1);
    await db.close();
  });
  test('Delete todo', () async {
    var db = await factory.openDatabase(inMemoryDatabasePath,
        options: getOpenDbForTodo());
    await db.insert(toDoTABLE, taskOne.toJson());
    var result = await db.delete(toDoTABLE,
        where: '${TodoModel.dbTime}=?',
        whereArgs: [taskOne.time.toIso8601String()]);
    expect(result, 1);
    await db.close();
  });

  test('Delete todo', () async {
    var db = await factory.openDatabase(inMemoryDatabasePath,
        options: getOpenDbForTodo());
    await db.insert(toDoTABLE, taskOne.toJson());
    var result = await db.delete(toDoTABLE,
        where: '${TodoModel.dbTime}=?',
        whereArgs: [taskOne.time.toIso8601String()]);
    expect(result, 1);
    await db.close();
  });
}
