import 'package:chat_app_firebase/app/modules/chat/chat_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatRoomView extends StatelessWidget {
  final ChatRoomController controller = Get.put(ChatRoomController());
  final messageController = TextEditingController();
  final String chatId;
  final String friendEmail;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  

  ChatRoomView({Key? key, required this.chatId, required this.friendEmail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? currentUser = _auth.currentUser.toString();
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat s prijateljem'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: controller.getMessages(chatId), // Use chatId for getting messages
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('Nema poruka.'));
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Greška: ${snapshot.error}'));
                  }

                  var messagesList = snapshot.data!.docs;
                  return ListView.builder(
                    reverse: true,
                    itemCount: messagesList.length,
                    itemBuilder: (context, index) {
                      var messageData = messagesList[index].data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(messageData['message'] ?? ''),
                      );
                    },
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Unesite poruku...',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    String message = messageController.text.trim();
                    if (message.isNotEmpty) {
                      controller.sendMessage(chatId, currentUser, message);
                      messageController.clear();
                    }
                  },
                  child: Text('Pošalji'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}