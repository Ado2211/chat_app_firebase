import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:get/get.dart';

class ChatRoomController extends GetxController {
 

  void sendMessage(
      String chatId, String senderEmail, String messageContent) async {
    CollectionReference chats = FirebaseFirestore.instance.collection('chats');

    await chats.doc(chatId).collection('chat').add({
      'senderEmail': senderEmail,
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
