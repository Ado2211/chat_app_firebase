import 'package:chat_app_firebase/app/modules/chat/chat_controller.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatRoomView extends StatelessWidget {
  final ChatRoomController controller = Get.put(ChatRoomController());
  final TextEditingController messageController = TextEditingController();
  final String friendUid;

  ChatRoomView({required this.friendUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat sa prijateljem'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: controller.getMessages(friendUid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (!snapshot.hasData ||
                      snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('Nema poruka.'));
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Greška: ${snapshot.error}'));
                  }

                  var messagesList = snapshot.data!.docs;
                  return ListView.builder(
                    reverse: true,
                    itemCount: messagesList.length,
                    itemBuilder: (context, index) {
                      var messageData = messagesList[index].data();
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
                      controller.sendMessage(message, friendUid);
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