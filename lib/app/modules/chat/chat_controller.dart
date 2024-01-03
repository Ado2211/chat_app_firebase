import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ChatRoomController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void sendMessage(String chatId, String senderEmail, String messageContent) async {
  CollectionReference chats = FirebaseFirestore.instance.collection('chats');

  await chats.doc(chatId).collection('chat').add({
    'sender': senderEmail,
    'message': messageContent,
    'timestamp': DateTime.now(),
    'isRead': false,
  });
}

Stream<QuerySnapshot> getMessages(String chatId) {
  CollectionReference chats = FirebaseFirestore.instance.collection('chats');

  return chats
      .doc(chatId)
      .collection('chat')
      .orderBy('timestamp', descending: true)
      .snapshots();
}
}
