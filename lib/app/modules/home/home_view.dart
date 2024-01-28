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
        flexibleSpace: Container(
          padding: EdgeInsets.fromLTRB(16, 70, 16, 56),
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
                  fontSize: 20,
                  color: Colors.white,
                  letterSpacing: 2.5,
                ),
              ),
              PopupMenuButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  child: Icon(
                    Icons.person,
                    size: 40,
                  ),
                ),
                itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                  PopupMenuItem(
                    value: 'profile',
                    child: Text('Profile'),
                  ),
                  PopupMenuItem(
                    value: 'logout',
                    child: Text('Log Out'),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'profile') {
                    // Logika za opciju 'Profile'
                  } else if (value == 'logout') {
                    authC.logOut();
                  }
                },
              )
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                      final messageSentTime = friendData['timestamp'];

                      return ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        leading: Padding(
                          padding: EdgeInsets.only(left: 3),
                          child: Icon(
                            Icons.person,
                            size: 60,
                          ),
                        ),
                        title: Text(
                          username!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color.fromARGB(255, 85, 82, 82),
                          ),
                        ),
                        subtitle: Container(
                          margin: EdgeInsets.only(top: 8),
                          child: Text(
                            latestMessage!,
                          ),
                        ),
                        trailing: Text(
                          messageSentTime!,
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        onTap: () async {
                          String selectedFriendEmail = friendEmail!;

                          String? chatId = await controller.getChatId(
                            authC.auth.currentUser!.email!,
                            selectedFriendEmail,
                          );

                          if (chatId!.isNotEmpty) {
                            controller.openChat(
                                chatId, selectedFriendEmail, username);
                          } else {}
                          ;
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
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        selectedItemColor: Colors.black54,
        onTap: (index) {
          if (index == 0) {
          } else if (index == 1) {
          } else if (index == 2) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 240, 241, 248),
                          Color.fromARGB(255, 255, 255, 255),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp,
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Add friend',
                          style: TextStyle(
                            color: Color.fromARGB(255, 30, 85, 225),
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16.0),
                        TextField(
                          controller: friendEmailController,
                          style: TextStyle(
                              color: const Color.fromARGB(255, 67, 67, 67)),
                          decoration: InputDecoration(
                            hintText: 'Enter a friend\'s email',
                            hintStyle: TextStyle(
                                color: Color.fromARGB(255, 160, 181, 239)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 68, 114, 240)),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            labelStyle: TextStyle(
                                color: Color.fromARGB(255, 68, 114, 240)),
                          ),
                        ),
                        SizedBox(height: 26.0),
                        MaterialButton(
                          onPressed: () {
                            String friendEmail =
                                friendEmailController.text.trim();
                            controller.addFriend(friendEmail);
                            friendEmailController.clear();
                            Navigator.of(context).pop();
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          color: Color.fromARGB(255, 94, 153, 241),
                          minWidth: 50,
                          height: 50,
                          child: Text(
                            'Add',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (index == 3) {
          } else if (index == 4) {}
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call),
            label: '',
          ),
          BottomNavigationBarItem(
              icon: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(20.0),
                  color: Color.fromARGB(255, 94, 153, 241),
                ),
                width: 50,
                height: 50,
                child: Center(
                  child: Icon(
                    Icons.add,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
              ),
              label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: '',
          ),
        ],
      ),
    );
  }
}
