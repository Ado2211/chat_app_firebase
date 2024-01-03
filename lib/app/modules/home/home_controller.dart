import 'dart:async';

import 'package:chat_app_firebase/app/modules/chat/chat_view.dart';
import 'package:chat_app_firebase/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Rx<List<String>> friendsList = Rx<List<String>>([]);

  Stream<List<String>> getFriendsByEmail(String userEmail) {
  StreamController<List<String>> friendsStreamController = StreamController<List<String>>();

  _firestore
      .collection('users')
      .where('email', isEqualTo: userEmail)
      .limit(1)
      .snapshots()
      .listen((snapshot) async {
    if (snapshot.docs.isNotEmpty) {
      final userId = snapshot.docs.first.id;
      _firestore
          .collection('users')
          .doc(userId)
          .collection('friends')
          .snapshots()
          .listen((friendsSnapshot) {
        final List<String> friendsEmails = [];
        for (var friendDoc in friendsSnapshot.docs) {
          final friendData = friendDoc.data();
          final friendEmail = friendData['email'];
          if (friendEmail != null) {
            friendsEmails.add(friendEmail);
          }
        }
        friendsStreamController.add(friendsEmails);
      });
    } else {
      friendsStreamController.add([]); // Vraćamo praznu listu ako korisnik nije pronađen
    }
  });

  return friendsStreamController.stream;
}

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

          if (snapshot.docs.isNotEmpty) {
            // Emitiranje nove liste prijatelja
          }

          Get.snackbar('Uspjeh', 'Prijatelj uspješno dodan');
        } else {
          Get.snackbar('Greška', 'Korisnik sa zadatim emailom ne postoji');
        }
      }
    } catch (e) {
      Get.snackbar('Greška', 'Greška prilikom dodavanja prijatelja: $e');
    }
  }

  void goToChatRoom(String chat_id, String email, String friendEmail) async {
    CollectionReference chats = _firestore.collection('chats');
    CollectionReference users = _firestore.collection('users');

    final updateStatusChat = await chats
        .doc(chat_id)
        .collection("chat")
        .where("isRead", isEqualTo: false)
        .where("posiljaoc", isEqualTo: email)
        .get();

    updateStatusChat.docs.forEach((element) async {
      await chats
          .doc(chat_id)
          .collection("chat")
          .doc(element.id)
          .update({"isRead": true});
    });

    await users
        .doc(email)
        .collection("chats")
        .doc(chat_id)
        .update({"total_unread": 0});

    Get.to(ChatRoomView(chatId: chat_id, friendEmail: friendEmail));
  }
}
