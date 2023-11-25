import 'package:chat_app_firebase/app/modules/home/home_view.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_app_firebase/app/modules/login/login_view.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  late Rxn<User?> _user;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void onReady() {
    super.onReady();
    _user = Rxn<User?>(auth.currentUser);
    // user notifier
    _user.bindStream(auth.userChanges());
    ever(_user, _initialScreen);
  }

  _initialScreen(User? user) {
    if (user == null) {
      print("login page");
      Get.offAll(() => LoginView());
    } 
  }

  void register(String email, password) async {
    try {
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      Get.snackbar(
        "About User",
        "User message",
        snackPosition: SnackPosition.BOTTOM,
        titleText: Text(
          "Account creation failed",
          style: TextStyle(color: Color.fromARGB(255, 207, 8, 8)),
        ),
        messageText: Text(
          e.toString(),
          style: TextStyle(color: const Color.fromARGB(255, 237, 82, 82)),
        ),
      );
    }
  }

  void login(String email, password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      Get.snackbar(
        "About Login",
        "Login message",
        snackPosition: SnackPosition.BOTTOM,
        titleText: Text(
          "Login failed",
          style: TextStyle(color: Color.fromARGB(255, 207, 8, 8)),
        ),
        messageText: Text(
          e.toString(),
          style: TextStyle(color: const Color.fromARGB(255, 237, 82, 82)),
        ),
      );
    }
  }

  void logOut() async {
    await auth.signOut();
  }
}
