import 'package:chat_app_firebase/app/modules/auth/auth_controller.dart';
import 'package:chat_app_firebase/app/modules/home/home_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

class HomeView extends StatelessWidget {
  final authC = Get.find<AuthController>();
  final HomeController controller = Get.put(HomeController());
  final TextEditingController friendEmailController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Chats'),
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                authC.logOut();
              },
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 240, 162, 88),
                Color.fromARGB(255, 210, 58, 152),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 1.2],
              tileMode: TileMode.clamp,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Existing UI components
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<Map<String, String>>>(
                stream: controller
                    .getFriendsByEmail(authC.auth.currentUser!.email!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Nema prijatelja.'));
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Greška: ${snapshot.error}'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final friendData = snapshot.data![index];
                      final username = friendData['username'];
                      final friendEmail = friendData['email'];

                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            username!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 85, 82, 82),
                            ),
                          ),
                          subtitle: Text(friendEmail!),
                          trailing: Icon(Icons.arrow_forward),
                          onTap: () async {
                            String selectedFriendEmail = friendEmail;

                            String? chatId = await controller.getChatId(
                              authC.auth.currentUser!.email!,
                              selectedFriendEmail,
                            );

                            if (chatId!.isNotEmpty) {
                              controller.openChat(chatId, selectedFriendEmail);
                            } else {
                              // Handle the case when chatId is empty
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          margin: EdgeInsets.only(bottom: 40.0),
          width: 200.0,
          height: 50.0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 240, 162, 88),
                Color.fromARGB(255, 210, 58, 152),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,
            ),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Add Friend'),
                    content: TextField(
                      controller: friendEmailController,
                      decoration: InputDecoration(
                        labelText: 'Enter a friend\'s email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          String friendEmail =
                              friendEmailController.text.trim();
                          controller.addFriend(friendEmail);
                          friendEmailController.clear();
                          Navigator.of(context).pop();
                        },
                        child: Text('Add'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: Icon(
              Icons.person_add,
              color: Colors.white, // Postavljanje boje ikone
            ),
            label: Text(
              'Add Friend',
              style: TextStyle(
                color: Colors.white, // Postavljanje boje teksta
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
