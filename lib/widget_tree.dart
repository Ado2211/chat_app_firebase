import 'package:flutter/material.dart';
import 'package:chat_app_firebase/auth.dart';
import 'package:chat_app_firebase/pages/home_page.dart';
import 'package:chat_app_firebase/pages/login_register_page.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({Key? key}) : super(key: key);

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Homepage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}