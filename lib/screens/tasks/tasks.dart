import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:to_do/models/user.dart';
import 'package:to_do/todo_database/todo_database.dart';
import 'package:to_do/utils/restart_widget.dart';

import '../../models/task.dart';
import '../../models/todoList.dart';
import 'task.dart';

class Tasks extends StatelessWidget {
  final TodoListModel todoList = TodoListModel();

  Tasks(this.user);

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          user.name + ' Todo',
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        actions: [
          IconButton(
              icon: Icon(
                Icons.exit_to_app,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext _) => SignOutDialog(
                        () => RestartWidget.restartApp(_),
                        todoList.todoList.isNotEmpty));
              })
        ],
      ),
      body: ChangeNotifierProvider.value(
        value: todoList,
        child: Column(children: [
          Expanded(child: Consumer<TodoListModel>(builder: todoListBuilder)),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => onPressed(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void onSave(String task) {
    if (task.isNotEmpty) {
      todoList.addTodo(TodoModel(todoTitle: task, time: DateTime.now()));
    }
  }

  void delete(TodoModel task) {
    todoList.deleteTask(task);
  }

  Widget todoListBuilder(
      BuildContext context, TodoListModel value, Widget child) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return value.todoList.isNotEmpty
        ? ListView(
            children: value.todoList.map((TodoModel task) {
              return ChangeNotifierProvider.value(
                  value: task, child: TaskWidget(delete));
            }).toList(),
          )
        : Center(
            child: Text(
            'No Todo yet, Add new to keep in track',
            style: textTheme.bodyText1.copyWith(color: textTheme.caption.color),
          ));
  }

  void onPressed(context) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.elliptical(20, 10)),
        ),
        isScrollControlled: true,
        builder: (context) => Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: AddNewToDo(onSave),
            ));
  }
}

class AddNewToDo extends StatefulWidget {
  final ValueChanged<String> onSave;

  const AddNewToDo(this.onSave, {Key key}) : super(key: key);

  @override
  State<AddNewToDo> createState() => _AddNewToDoState();
}

class _AddNewToDoState extends State<AddNewToDo> with TickerProviderStateMixin {
  TextEditingController toDoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.elliptical(4, 4)),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(14),
            child: TextField(
              controller: toDoController,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.done,
              style: textTheme.subtitle1.copyWith(fontWeight: FontWeight.w600),
              maxLines: null,
              decoration: InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: IconButton(
                      icon: Text(
                        'Save'.toUpperCase(),
                        style: textTheme.subtitle1
                            .copyWith(color: theme.primaryColor),
                      ),
                      onPressed: () {
                        widget.onSave(toDoController.text.trim());
                        Navigator.pop(context);
                      },
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  fillColor: theme.primaryColor.withOpacity(.4),
                  hintText: 'Add new To Do'),
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (newTask) {
                widget.onSave(toDoController.text.trim());
                Navigator.pop(context);
              },
              autofocus: true,
            ),
          ),
        ],
      ),
    );
  }
}

class SignOutDialog extends StatefulWidget {
  SignOutDialog(this.sigOut, this.isNotEmpty);

  final VoidCallback sigOut;
  final bool isNotEmpty;

  @override
  State<StatefulWidget> createState() => SignOutDialogState();
}

class SignOutDialogState extends State<SignOutDialog>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.elasticInOut);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  ThemeData theme;

  TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    textTheme = theme.textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Material(
          color: Colors.transparent,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24),
                decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                      child: Text(
                        "Are you sure you want to Sign out?",
                        style: textTheme.headline6,
                      ),
                    ),
                    if (widget.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(.3),
                            borderRadius: BorderRadius.circular(4)),
                        child: ListTile(
                          title:
                              Text("Note: Saved Todo list will get cleared."),
                          trailing: Icon(
                            Icons.info_outline,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            child: Text("Cancel".toUpperCase()),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          TextButton(
                            child: Text("Yes".toUpperCase()),
                            onPressed: () async {
                              await TodoDatabase.get().truncateAllTable();
                              widget.sigOut();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
