import 'package:chat_app_firebase/app/modules/auth/auth_controller.dart';
import 'package:chat_app_firebase/app/modules/home/home_controller.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  final authC = Get.find<AuthController>();
  final HomeController controller = Get.put(HomeController());
  final TextEditingController friendEmailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 130,
        automaticallyImplyLeading: false,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.elliptical(90, 90),
            bottomRight: Radius.elliptical(90, 90),
          ),
        ),
        flexibleSpace: Container(
          padding: EdgeInsets.fromLTRB(16, 70, 16, 56),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  FontAwesomeIcons.equals,
                  color: Colors.white,
                ),
              ),
              Text(
                'MESSAGES',
                style: TextStyle(
                  fontFamily: 'Lato-Regular', 
                  fontSize: 24,
                  color: Colors.white,
                  letterSpacing:
                      2.5, // Prilagodi vrijednost kako bi postigao željeni razmak
                ),
              ),
              PopupMenuButton(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white,
                ),
                itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                  const PopupMenuItem(
                    value: 'profile',
                    child: Text('Profile'),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Text('Log Out'),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'profile') {
                    // Logika za otvaranje ekrana profila
                  } else if (value == 'logout') {
                    authC.logOut();
                  }
                },
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
                      final latestMessage = friendData['message'];

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
                          subtitle: Text(latestMessage!),
                          trailing: Icon(Icons.arrow_forward),
                          onTap: () async {
                            String selectedFriendEmail = friendEmail!;

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
