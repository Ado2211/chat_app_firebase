import 'package:chat_app_firebase/app/modules/chat/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatRoomView extends StatelessWidget {
  final ChatRoomController controller = Get.put(ChatRoomController());
  final messageController = TextEditingController();
  final String chatId;
  final String friendEmail;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ChatRoomView({Key? key, required this.chatId, required this.friendEmail})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? currentUser = _auth.currentUser.toString();
    return Scaffold(
      appBar: AppBar(
        elevation: 15,
        shadowColor: Color.fromARGB(255, 52, 75, 226),
        toolbarHeight: 130,
        automaticallyImplyLeading: false,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.elliptical(130, 70),
            bottomRight: Radius.elliptical(70, 130),
          ),
        ),
        flexibleSpace: Container(
          padding: EdgeInsets.fromLTRB(16, 40, 16, 26),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 68, 114, 240),
                Color.fromARGB(255, 123, 146, 238),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    Get.back();
                  },
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    'assets/img/profile3.png',
                    width: 60,
                    height: 60,
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  children: [
                    Text(
                      'Username',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color.fromARGB(255, 254, 254, 254),
                      ),
                    ),
                    Text(
                      'username',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(255, 254, 254, 254),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: controller.getMessages(chatId),
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
                      var messageData =
                          messagesList[index].data() as Map<String, dynamic>;
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
