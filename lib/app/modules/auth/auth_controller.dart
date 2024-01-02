
import 'package:chat_app_firebase/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:get/get.dart';

import 'package:chat_app_firebase/app/models/users_model.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  late Rxn<User?> _user;
 final FirebaseAuth auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
 

  @override
  void onReady() {
    super.onReady();
    _user = Rxn<User?>(auth.currentUser);

    _user.bindStream(auth.userChanges());
    ever(_user, _initialScreen);
  }

  _initialScreen(User? user) {
    if (user == null) {
      print("login page");
      Get.toNamed(Routes.LOGIN);
    } else {
      Get.toNamed(Routes.HOME);
    }
  }

 Future<void> register(String email, String password) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
  
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
         
        });

        Get.snackbar('Uspjeh', 'Registracija uspješna');
      }
    } catch (e) {
      Get.snackbar(
        'Greška',
        'Greška prilikom registracije: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void login(String email, password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (userCredential.user != null) {
        Get.snackbar('Success', 'Login successful');
      }
    } catch (e) {
      Get.snackbar(
        'Greška',
        'Greška prilikom registracije: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void logOut() async {
    await auth.signOut();
    Get.snackbar('Uspjeh', 'Registracija uspješna');
  }
}
