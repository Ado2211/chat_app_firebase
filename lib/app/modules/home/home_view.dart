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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Prijatelji'),
            IconButton(
              icon: Icon(Icons.exit_to_app), // Ikona za odjavu
              onPressed: () {
                // Logika za odjavu ili navigacija na stranicu za odjavu
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
            TextField(
              controller: friendEmailController,
              decoration: InputDecoration(
                labelText: 'Unesite email prijatelja',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                hintText: 'primjer@example.com',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                String friendEmail = friendEmailController.text.trim();
                controller.addFriend(friendEmail);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.transparent, // Postavi transparentnu pozadinu
                padding: EdgeInsets.all(
                    0), // Postavi padding na 0 kako bi se ispravno prikazao gradient
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      8.0), // Opcionalno: dodaj zaobljenje rubova
                ),
                elevation: 0, // Ukloni sjenu
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 240, 162, 88),
                      Color.fromARGB(255, 210, 58, 152)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.0, 1.2],
                    tileMode: TileMode.clamp,
                  ),
                  borderRadius: BorderRadius.circular(8.0), // Zaobljenje rubova
                ),
                child: Container(
                  constraints: BoxConstraints(
                      minWidth: 88.0,
                      minHeight: 36.0), // Opcionalno: postavi dimenzije
                  alignment: Alignment.center,
                  child: Text(
                    'Dodaj prijatelja',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<String>>(
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
                      var friendEmail = snapshot.data![index];

                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            friendEmail,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 85, 82, 82)),
                          ),
                          trailing: Icon(Icons.arrow_forward),
                          onTap: () async {
                            String selectedFriendEmail = snapshot.data![index];

                            String? chatId = await controller.getChatId(
                              authC.auth.currentUser!.email!,
                              selectedFriendEmail,
                            );

                            if (chatId!.isNotEmpty) {
                              controller.openChat(chatId, selectedFriendEmail);
                            } else {}
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
    );
  }
}
