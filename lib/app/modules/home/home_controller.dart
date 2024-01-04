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
    StreamController<List<String>> friendsStreamController =
        StreamController<List<String>>();

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
        friendsStreamController
            .add([]); // Vraćamo praznu listu ako korisnik nije pronađen
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

          // Pronalaženje ili stvaranje chata između korisnika
          DocumentReference currentUserChatRef = _firestore
              .collection('users')
              .doc(currentUser.uid)
              .collection('chats')
              .doc(friendEmail);

          DocumentReference friendChatRef = _firestore
              .collection('users')
              .doc(friendUid)
              .collection('chats')
              .doc(currentUser.email);

          bool currentUserChatExists = (await currentUserChatRef.get()).exists;
          bool friendChatExists = (await friendChatRef.get()).exists;

          String? chatId;

          if (currentUserChatExists && friendChatExists) {
            var currentUserChatData = (await currentUserChatRef.get()).data()
                as Map<String, dynamic>?;
            if (currentUserChatData != null) {
              chatId = currentUserChatData['chatId'];
            }
          } else {
            DocumentReference newChatRef = _firestore.collection('chats').doc();
            chatId = newChatRef.id;

            await newChatRef.set({
              'participants': [currentUser.email, friendEmail],
            });

            await currentUserChatRef.set({'chatId': chatId});
            await friendChatRef.set({'chatId': chatId});
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

 Future<String?> getChatId(String currentUserEmail, String friendEmail) async {
  try {
    DocumentSnapshot currentUserChatSnapshot = await _firestore
        .collection('users')
        .doc(currentUserEmail)
        .collection('chats')
        .doc(friendEmail)
        .get();

    if (currentUserChatSnapshot.exists) {
      return currentUserChatSnapshot.get('chatId');
    } else {
      // Kreirajte novi chat ako chat ne postoji
      DocumentReference newChatRef = _firestore.collection('chats').doc();
      String newChatId = newChatRef.id;

      // Postavite chatId za korisnika i prijatelja
      await _firestore
          .collection('users')
          .doc(currentUserEmail)
          .collection('chats')
          .doc(friendEmail)
          .set({'chatId': newChatId});

      await _firestore
          .collection('users')
          .doc(friendEmail)
          .collection('chats')
          .doc(currentUserEmail)
          .set({'chatId': newChatId});

      return newChatId;
    }
  } catch (e) {
    print('Greška prilikom dohvatanja ili kreiranja chatId-a: $e');
    return null;
  }
}

  void openChat(String chatId, String friendEmail) {
    Get.to(ChatRoomView(chatId: chatId, friendEmail: friendEmail));
  }
}
