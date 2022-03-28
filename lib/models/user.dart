import 'package:flutter/foundation.dart';
import 'package:to_do/todo_database/todo_database.dart';

class UserUseCase extends ChangeNotifier {
  UserModel user;
  bool isLoggedIn = false;
  bool splashScreen = true;
  bool isLoading = true;

  UserUseCase() {
    getUser();
  }

  Future<void> getUser() async {
    user = await TodoDatabase.get().getUser();
    isLoggedIn = user != null;
    await Future.delayed(Duration(seconds: 2));
    splashScreen = isLoading = false;
    print('isLoggedIn');
    print(isLoggedIn);
    notifyListeners();
  }

  Future<void> addUser(UserModel userModel) async {
    isLoading = true;
    notifyListeners();
    await TodoDatabase.get().addUser(userModel);
  }
}

class UserModel {
  static final dbName = 'name';
  static final dbEmail = 'email';

  String name;
  String email;

  UserModel(this.name, {this.email = ''});

  UserModel.fromJson(Map<String, dynamic> json)
      : name = json[dbName],
        email = json[dbEmail];

  Map<String, dynamic> toJson() => {
        dbName: name,
        dbEmail: email,
      };
}
