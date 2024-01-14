import 'dart:async';

import 'package:chat_app_firebase/app/modules/auth/auth_controller.dart';
import 'package:chat_app_firebase/app/modules/chat/chat_view.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final authC = Get.find<AuthController>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Rx<List<String>> friendsList = Rx<List<String>>([]);

  Future<String?> getLatestMessage(String chatId) async {
    try {
      QuerySnapshot<Object?> snapshot = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('chat')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final lastMessageData =
            snapshot.docs.first.data() as Map<String, dynamic>;
        return lastMessageData['message'];
      } else {
        return null;
      }
    } catch (e) {
      print('Greška prilikom dohvaćanja zadnje poruke: $e');
      return null;
    }
  }

  Stream<List<Map<String, String>>> getFriendsByEmail(String userEmail) {
    StreamController<List<Map<String, String>>> friendsStreamController =
        StreamController<List<Map<String, String>>>();

    void refreshData() async {
      if (!friendsStreamController.isClosed) {
        final snapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: userEmail)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final userId = snapshot.docs.first.id;

          final friendsSnapshot = await _firestore
              .collection('users')
              .doc(userId)
              .collection('friends')
              .get();

          final List<Map<String, String>> friendsData = [];

          for (var friendDoc in friendsSnapshot.docs) {
            final friendData = friendDoc.data();
            final friendEmail = friendData['email'];

            if (friendEmail != null) {
              final friendUserData = await getUserDataByEmail(friendEmail);

              if (friendUserData != null) {
                final friendUsername = friendUserData['username'];
                final chatId = await getChatId(
                  authC.auth.currentUser!.email!,
                  friendEmail,
                );

                if (chatId != null) {
                  final latestMessage = await getLatestMessage(chatId);

                  friendsData.add({
                    'email': friendEmail,
                    'username': friendUsername,
                    'message': latestMessage ?? '',
                  });
                }
              }
            }
          }

          friendsStreamController.add(friendsData);
        } else {
          friendsStreamController.add([]);
        }
      }
    }

    Stream.periodic(const Duration(seconds: 10)).listen((_) => refreshData());

    refreshData();

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
