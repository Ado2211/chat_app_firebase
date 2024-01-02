import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ChatRoomController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void sendMessage(String message, String friendUid) async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        await _firestore
            .collection('chats')
            .doc(currentUser.uid)
            .collection('messages')
            .add({
          'message': message,
          'senderUid': currentUser.uid,
          'timestamp': DateTime.now(),
        });

        await _firestore
            .collection('chats')
            .doc(friendUid)
            .collection('messages')
            .add({
          'message': message,
          'senderUid': currentUser.uid,
          'timestamp': DateTime.now(),
        });
      }
    } catch (e) {
      print('Greška prilikom slanja poruke: $e');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(String friendUid) {
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      return _firestore
          .collection('chats')
          .doc(currentUser.uid)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots();
    }

    return Stream.empty();
  }
}