import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:to_do/screens/login/login.dart';

class RestartWidget extends StatefulWidget {
  RestartWidget({this.child});

  final Widget child;

  static restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>().restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: MaterialApp(
        home: LoginScreen(),
        theme: FlexColorScheme.light(
          scheme: FlexScheme.money,
        ).toTheme.copyWith(
                textTheme: GoogleFonts.latoTextTheme(
              Theme.of(context)
                  .textTheme, // If this is not set, then ThemeData.light().textTheme is used.
            )),
      ),
    );
  }
}
