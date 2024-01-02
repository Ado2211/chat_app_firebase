import 'package:chat_app_firebase/app/modules/chat/chat_view.dart';
import 'package:chat_app_firebase/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addFriend(String friendEmail) async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: friendEmail)
            .get();

        if (snapshot.docs.isNotEmpty) {
          String friendUid = snapshot.docs.first.id;

          await _firestore
              .collection('users')
              .doc(currentUser.uid)
              .collection('friends')
              .doc(friendUid)
              .set({'email': friendEmail});

          Get.snackbar('Uspjeh', 'Prijatelj uspješno dodan');

          openChatRoom(friendUid); // Ovdje otvaramo chat s prijateljem
        } else {
          Get.snackbar('Greška', 'Korisnik sa zadatim emailom ne postoji');
        }
      }
    } catch (e) {
      Get.snackbar('Greška', 'Greška prilikom dodavanja prijatelja: $e');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getFriends() {
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      return _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('friends')
          .snapshots();
    }

    return Stream.empty();
  }

  void openChatRoom(String friendUid) {
  Get.to(ChatRoomView(friendUid: friendUid));
}
}