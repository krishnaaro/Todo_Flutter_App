import 'package:flutter/foundation.dart';

class TodoModel extends ChangeNotifier {
  static final dbTodoTitle = 'todoTitle';
  static final dbIsCompleted = 'isCompleted';
  static final dbTime = 'time';

  final String todoTitle;
  bool isCompleted;
  DateTime time;

  TodoModel({this.todoTitle = '', this.isCompleted = false, this.time});

  TodoModel.fromJson(Map<String, dynamic> json)
      : todoTitle = json[dbTodoTitle],
        isCompleted = json[dbIsCompleted] == 'yes',
        time = DateTime.parse(json[dbTime]);

  Map<String, dynamic> toJson() => {
        dbTodoTitle: todoTitle,
        dbIsCompleted: isCompleted ? 'yes' : 'no',
        dbTime: time.toIso8601String()
      };

  void toggle() {
    isCompleted = !isCompleted;
    notifyListeners();
  }
}
