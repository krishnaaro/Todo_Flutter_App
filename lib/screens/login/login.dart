import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:to_do/models/user.dart';
import 'package:to_do/screens/tasks/tasks.dart';
import 'package:to_do/utils/text_validator.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final UserUseCase todoList = UserUseCase();

  ThemeData theme;
  TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    textTheme = theme.textTheme;

    return ChangeNotifierProvider.value(
        value: todoList,
        child: Consumer<UserUseCase>(builder: todoListBuilder));
  }

  Future<void> onSave(UserModel user, BuildContext context) async {
    await todoList.addUser(user);
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Tasks(user)));
  }

  void onPressed(context) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        ),
        isScrollControlled: true,
        builder: (context) => Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: AddUser((_) => onSave(_, context)),
            ));
  }

  Widget todoListBuilder(
      BuildContext context, UserUseCase value, Widget child) {
    return todoList.isLoggedIn
        ? Tasks(todoList.user)
        : Scaffold(
            body: Center(
              child: ShaderMask(
                  shaderCallback: (bounds) {
                    return SweepGradient(
                        startAngle: 0.1,
                        endAngle: 1.0,
                        colors: [
                          Colors.indigo,
                          Colors.blue,
                          Colors.red,
                          Colors.orange
                        ]).createShader(bounds);
                  },
                  child: Image.asset(
                    'asset/todo.jpeg',
                  )),
            ),
            floatingActionButton: !todoList.isLoggedIn && !todoList.isLoading
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Divider(
                        height: .5,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextButton(
                        onPressed: () => onPressed(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          child: Text(
                            'Proceed Login',
                            style: textTheme.button
                                .copyWith(color: theme.primaryColor),
                          ),
                        ),
                      ),
                    ],
                  )
                : null);
  }
}

class AddUser extends StatefulWidget {
  final ValueChanged<UserModel> onSave;

  const AddUser(this.onSave, {Key key}) : super(key: key);

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> with TickerProviderStateMixin {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  FocusNode nameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();

  BoxDecoration getBorder(Color color, {bool elevation = false}) =>
      BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        color: color,
        boxShadow: [
          if (elevation)
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.0, 0.8), //(x,y)
              blurRadius: 2.0,
            ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    return Container(
      decoration: getBorder(Colors.grey.shade50),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Stack(
            children: [
              Container(
                  decoration: getBorder(Colors.grey.shade200, elevation: true),
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Text(
                      'User Details',
                      style: textTheme.headline6
                          .copyWith(color: theme.primaryColor),
                    ),
                  )),
              Positioned(
                  right: 12,
                  top: 0,
                  bottom: 0,
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      color: theme.primaryColor,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ))
            ],
          ),
          SizedBox(
            height: 12,
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: nameController,
              textInputAction: TextInputAction.next,
              maxLines: null,
              decoration: InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.only(left: 10),
                  fillColor: theme.primaryColor.withOpacity(.1),
                  errorText: TodoValidator()
                      .validateUserName(nameController.text.trim()),
                  labelText: 'Name*'),
              textCapitalization: TextCapitalization.sentences,
              focusNode: nameFocusNode,
              onSubmitted: (newTask) {
                nameFocusNode.unfocus();
                emailFocusNode.requestFocus();
              },
              autofocus: true,
            ),
          ),
          Divider(
            height: .5,
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: emailController,
              focusNode: emailFocusNode,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              maxLines: null,
              decoration: InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.only(left: 10),
                  labelText: 'Email'),
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) {
                setState(() {});
              },
              onSubmitted: onSave,
              autofocus: true,
            ),
          ),
          Divider(
            height: .5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => onSave(''),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Text(
                    'Login',
                    style:
                        textTheme.subtitle1.copyWith(color: theme.primaryColor),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<bool> showToast(String text) async => Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);

  void onSave(String value) {
    if (nameController.text.isNotEmpty) {
      widget.onSave(UserModel(nameController.text.trim(),
          email: emailController.text.trim()));
      Navigator.pop(context);
    } else
      showToast('Please enter name');
  }
}
