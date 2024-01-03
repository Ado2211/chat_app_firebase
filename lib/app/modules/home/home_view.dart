import 'package:chat_app_firebase/app/modules/auth/auth_controller.dart';
import 'package:chat_app_firebase/app/modules/home/home_controller.dart';
// Change the import path if needed
import 'package:chat_app_firebase/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  final authC = Get.find<AuthController>();
  final HomeController controller = Get.put(HomeController());
  final TextEditingController friendEmailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prijatelji'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: friendEmailController,
              decoration: InputDecoration(
                labelText: 'Email prijatelja',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                String friendEmail = friendEmailController.text.trim();
                controller.addFriend(friendEmail);
              },
              child: Text('Dodaj prijatelja'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<String>>(
                stream: controller.getFriendsByEmail(authC.auth.currentUser!.email!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Nema prijatelja.'));
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Greška: ${snapshot.error}'));
                  }

                  // Prikaz liste prijatelja
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(snapshot.data![index]),
                        // treba dodati go to chat room
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
