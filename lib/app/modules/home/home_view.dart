import 'package:chat_app_firebase/app/modules/auth/auth_controller.dart';
import 'package:chat_app_firebase/app/modules/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  final authC = Get.find<AuthController>();
  final HomeController controller = Get.put(HomeController());
  final TextEditingController friendEmailController = TextEditingController();

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
              child: StreamBuilder<List<FriendInfo>>(
                stream: controller
                    .getFriendsByEmail(authC.auth.currentUser!.email!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('There are no friends added'));
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var friendInfo = snapshot.data![index];

                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey,
                          radius: 30,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        title: Text(
                          friendInfo.username,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          friendInfo.email,
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                        onTap: () async {
                          String selectedFriendEmail = friendInfo.email;

                          String? chatId = await controller.getChatId(
                            authC.auth.currentUser!.email!,
                            selectedFriendEmail,
                          );

                          if (chatId!.isNotEmpty) {
                            controller.openChat(chatId, selectedFriendEmail);
                          } else {
                            // Logic if chatId is not found or there is no chat with that friend
                          }
                        },
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
                    String friendEmail = friendEmailController.text.trim();
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
