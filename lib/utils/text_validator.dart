class TodoValidator {
  String validateUserName(String name) {
    if (name == null || (name != null && name.isEmpty)) {
      return TodoConstants.userNameMandatory;
    } else
      return null;
  }
}

class TodoConstants {
  static String userNameMandatory = 'User name Value can\'t be empty';
}
