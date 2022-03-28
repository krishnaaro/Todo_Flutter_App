import 'package:flutter/material.dart';
import 'screens/login/login.dart';
import 'utils/restart_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  return runApp(RestartWidget());
}
