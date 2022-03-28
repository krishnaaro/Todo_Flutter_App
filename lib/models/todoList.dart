import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:to_do/models/user.dart';

import '../todo_database/todo_database.dart';
import 'task.dart';

class TodoListModel extends ChangeNotifier {
  List<TodoModel> todoList = [];
  UserModel user;

  TodoListModel() {
    getTodo();
  }

  Future<void> getTodo() async {
    todoList = await TodoDatabase.get().getTodo();
    user = await TodoDatabase.get().getUser();

    notifyListeners();
  }

  Future<void> addTodo(TodoModel task) async {
    todoList.add(task);
    await TodoDatabase.get().addTodo(task);
    notifyListeners();
  }

  Future<void> updateDB(TodoModel task) async {
    await TodoDatabase.get().updateTodo(task);
  }

  Future<void> deleteTask(TodoModel task) async {
    todoList.remove(task);
    await TodoDatabase.get().deleteTodo(task).then((value) => print(value));
    notifyListeners();
  }

  Future signOut(BuildContext context) async {}
}
