
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';

class HomePage extends StatelessWidget {
  String? email;

  HomePage({Key? key, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double w = Get.size.width;
    double h = Get.size.height;

    return Scaffold(
      body: Column(children: [
        Text(
          "Wellcome",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
          ),
        ),
        Text(
          email!,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
          ),
        ),
        GestureDetector(
          onTap: () {
            AuthController.instance.logOut();
          },
          child: Container(
            width: w * 0.5,
            height: h * 0.08,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              image: DecorationImage(
                  image: AssetImage("assets/img/loginbtn.png"),
                  fit: BoxFit.cover),
            ),
            child: Center(
              child: Text(
                "Sign out",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
