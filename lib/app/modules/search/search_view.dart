
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:chat_app_firebase/app/modules/search/search_controller.dart';

class SearchWidget extends StatelessWidget  {
  final FriendController _friendsController = Get.put(FriendController());
  

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Friend'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Enter friend\'s email',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String email = emailController.text.trim();
                if (email.isNotEmpty) {
                  _friendsController.addNewConnection(email);
                } else {
                  Get.snackbar('Error', 'Please enter an email');
                }
              },
              child: Text('Add Friend'),
            ),
          ],
        ),
      ),
    );
  }
}