import 'dart:async';

import 'package:chat_app_firebase/app/modules/chat/chat_view.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Rx<List<String>> friendsList = Rx<List<String>>([]);

  Stream<Map<String, dynamic>?> getLastMessage(String chatId) {
  CollectionReference messagesCollection = FirebaseFirestore.instance.collection('chats').doc(chatId).collection('chat');

  return messagesCollection
      .orderBy('timestamp', descending: true)
      .limit(1)
      .snapshots()
      .map<Map<String, dynamic>?>((QuerySnapshot snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final lastMessageData = snapshot.docs.first.data() as Map<String, dynamic>;
          return {
            'sender': lastMessageData['sender'] ?? '',
            'text': lastMessageData['text'] ?? '',
          };
        } else {
          return null;
        }
      });
}

  Stream<List<Map<String, String>>> getFriendsByEmail(String userEmail) {
    StreamController<List<Map<String, String>>> friendsStreamController =
        StreamController<List<Map<String, String>>>();

    _firestore
        .collection('users')
        .where('email', isEqualTo: userEmail)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        final userId = snapshot.docs.first.id;

        _firestore
            .collection('users')
            .doc(userId)
            .collection('friends')
            .snapshots()
            .listen((friendsSnapshot) async {
          final List<Map<String, String>> friendsData = [];

          for (var friendDoc in friendsSnapshot.docs) {
            final friendData = friendDoc.data();
            final friendEmail = friendData['email'];

            if (friendEmail != null) {
              // Dohvati podatke o prijatelju, ne koristi podatke o trenutnom korisniku
              final friendUserData = await getUserDataByEmail(friendEmail);

              if (friendUserData != null) {
                final friendUsername = friendUserData['username'];

                friendsData.add({
                  'email': friendEmail,
                  'username': friendUsername,
                });
              }
            }
          }

          friendsStreamController.add(friendsData);
        });
      } else {
        friendsStreamController.add([]);
      }
    });

    return friendsStreamController.stream;
  }

  Future<Map<String, dynamic>?> getUserDataByEmail(String userEmail) async {
    final userQuery = await _firestore
        .collection('users')
        .where('email', isEqualTo: userEmail)
        .get();

    if (userQuery.docs.isNotEmpty) {
      return userQuery.docs.first.data();
    } else {
      return null;
    }
  }

  Future<void> addFriend(String friendEmail) async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
            .collection('users')
            .where(
              'email',
              isEqualTo: friendEmail,
            )
            .get();

        if (snapshot.docs.isNotEmpty) {
          String friendUid = snapshot.docs.first.id;
          String friendUsername = snapshot.docs.first.data()['username'];

          await _firestore
              .collection('users')
              .doc(currentUser.uid)
              .collection('friends')
              .doc(friendUid)
              .set({
            'email': friendEmail,
            'username': friendUsername,
          });

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
        DocumentReference newChatRef = _firestore.collection('chats').doc();
        String newChatId = newChatRef.id;

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

class FriendInfo {
  final String email;
  final String username;

  FriendInfo({required this.email, required this.username});
}
