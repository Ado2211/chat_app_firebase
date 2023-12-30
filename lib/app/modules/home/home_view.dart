
import 'package:chat_app_firebase/app/modules/auth/auth_controller.dart';
import 'package:chat_app_firebase/app/modules/home/home_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(), // Inicijalizacija kontrolera
      builder: (homeController) {
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: homeController.chatsStream(AuthController.instance.user.value.email!), // Zamijenite s pravim emailom korisnika
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('Nema dostupnih razgovora.'));
            } else if (snapshot.hasError) {
              return Center(child: Text('Greška: ${snapshot.error}'));
            }

            var listDocsChats = snapshot.data!.docs;
            return ListView.builder(
              itemCount: listDocsChats.length,
              itemBuilder: (context, index) {
                var chatData = listDocsChats[index].data();
                return ListTile(
                  title: Text(chatData['name'] ?? ''),
                  subtitle: Text(chatData['lastMessage'] ?? ''),
                  onTap: () {
                    // Navigacija na detalje razgovora
                    String chatId = listDocsChats[index].id;
                    String friendEmail = chatData['friendEmail'];
                    homeController.goToChatRoom(
                      chatId,
                      AuthController.instance.user.value.email!,
                      friendEmail,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}