import 'package:chat_app_firebase/app/modules/auth/auth_controller.dart';
import 'package:chat_app_firebase/app/modules/chat/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatRoomView extends StatelessWidget {
  final authC = Get.find<AuthController>();
  final ChatRoomController controller = Get.put(ChatRoomController());
  final messageController = TextEditingController();
  final String chatId;
  final String friendEmail;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String username;

  ChatRoomView(
      {Key? key,
      required this.chatId,
      required this.friendEmail,
      required this.username})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? currentUserEmail = _auth.currentUser!.email.toString();
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        toolbarHeight: 100,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          clipBehavior: Clip.antiAlias,
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
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(255, 4, 16, 120).withOpacity(0.7),
                offset: Offset(0, 5),
                blurRadius: 40,
              ),
            ],
          ),
          child: Stack(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                  Icon(
                    Icons.person,
                    size: 60,
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 12,
                      ),
                      Text(
                        username,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color.fromARGB(255, 254, 254, 254),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Online',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(255, 220, 220, 220),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          color: const Color.fromARGB(255, 255, 255, 255)
                              .withOpacity(0.2),
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.phone,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {},
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          color: const Color.fromARGB(255, 255, 255, 255)
                              .withOpacity(0.2),
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.videocam,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                  ],
                ),
              ),
            ],
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

                      bool isFriendMessage = messageData['senderEmail'] !=
                          authC.auth.currentUser!.email.toString();

                      return Align(
                        alignment: isFriendMessage
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.only(bottom: 26),
                          child: Column(
                            crossAxisAlignment: isFriendMessage
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: isFriendMessage
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  isFriendMessage
                                      ? Container()
                                      : Icon(
                                          Icons.person,
                                          size: 60,
                                        ),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Container(
                                      constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              2 /
                                              3),
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isFriendMessage
                                            ? Colors.blue
                                            : Colors.grey.shade200,
                                        borderRadius: BorderRadius.only(
                                          topLeft: isFriendMessage
                                              ? Radius.circular(15)
                                              : Radius.circular(15),
                                          topRight: isFriendMessage
                                              ? Radius.circular(15)
                                              : Radius.circular(15),
                                          bottomLeft: Radius.circular(15),
                                          bottomRight: Radius.circular(15),
                                        ),
                                      ),
                                      child: Text(
                                        messageData['message'] ?? '',
                                        style: TextStyle(
                                            color: isFriendMessage
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  isFriendMessage
                                      ? Icon(
                                          Icons.person,
                                          size: 60,
                                        )
                                      : Container(),
                                ],
                              ),
                              SizedBox(height: 8),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200], 
                borderRadius:
                    BorderRadius.circular(10.0), 
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      maxLines: null, 
                      decoration: InputDecoration(
                        hintText: 'Type Your Message',
                        border: InputBorder.none, 
                        contentPadding:
                            EdgeInsets.all(26.0), 
                      ),
                    ),
                  ),
                  SizedBox(width: 8), 
                  Container(
                    width: 60, 
                    height: 60, 
                    decoration: BoxDecoration(
                      color: Colors.blue, 
                      borderRadius:
                          BorderRadius.circular(10.0), 
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                          15.0), 
                      onTap: () {
                        String message = messageController.text.trim();
                        if (message.isNotEmpty) {
                          controller.sendMessage(chatId, currentUserEmail, message);
                          messageController.clear();
                        }
                      },
                      child: Center(
                        child: Icon(
                          Icons.send_outlined,
                          color: Colors.white, 
                          size: 30.0, 
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
