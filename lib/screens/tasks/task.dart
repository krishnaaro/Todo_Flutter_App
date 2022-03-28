import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/task.dart';
import '../../models/todoList.dart';

class TaskWidget extends StatefulWidget {
  TaskWidget(this.delete);

  final ValueChanged<TodoModel> delete;

  @override
  _TaskWidgetState createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  TextStyle _taskStyle(completed) {
    if (completed)
      return textTheme.subtitle1.copyWith(
        fontWeight: FontWeight.w500,
        color: textTheme.caption.color,
        decoration: TextDecoration.lineThrough,
      );
    else
      return textTheme.subtitle1.copyWith(fontWeight: FontWeight.w600);
  }

  ThemeData theme;

  TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    textTheme = theme.textTheme;
    return Consumer<TodoModel>(builder: (context, task, child) {
      return ListTile(
        title: CheckboxListTile(
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              task.todoTitle,
              style: _taskStyle(task.isCompleted),
            ),
          ),
          value: task.isCompleted,
          onChanged: (newValue) {
            task.toggle();
            Provider.of<TodoListModel>(context, listen: false).updateDB(task);
          },
          controlAffinity: ListTileControlAffinity.leading,
        ),
        trailing: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
            icon: Icon(
              Icons.delete,
              color: theme.secondaryHeaderColor.withOpacity(.7),
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      DeleteTodoDialog(task, widget.delete));
            },
          ),
        ),
        contentPadding: EdgeInsets.zero,
      );
    });
  }
}

class DeleteTodoDialog extends StatefulWidget {
  DeleteTodoDialog(this.task, this.delete);

  final TodoModel task;
  final ValueChanged<TodoModel> delete;

  @override
  State<StatefulWidget> createState() => DeleteTodoDialogState();
}

class DeleteTodoDialogState extends State<DeleteTodoDialog>
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
                        "Confirm delete ... !",
                        style: textTheme.headline6,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(.4),
                          borderRadius: BorderRadius.circular(4)),
                      child: ListTile(
                        title: Text(
                          "${widget.task.todoTitle}",
                          style: textTheme.subtitle1
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          widget.task.isCompleted ? 'Completed' : 'Pending',
                          style: textTheme.bodyText1.copyWith(
                              color: widget.task.isCompleted
                                  ? theme.primaryColor
                                  : Colors.red),
                        ),
                        trailing: Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
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
                            onPressed: () {
                              widget.delete(widget.task);
                              Navigator.pop(context);
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
