import 'package:chat_app_firebase/app/modules/auth/auth_controller.dart';
import 'package:chat_app_firebase/app/modules/auth/login/login_controller.dart';
import 'package:chat_app_firebase/app/modules/auth/register/register_view.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/clipper.dart';


class LoginView extends GetView<LoginController>  {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var emailController = TextEditingController();
    var passwordController = TextEditingController();
    double w = Get.size.width;
    double h = Get.size.height;
    return Scaffold(
      body: SizedBox(
        height: h,
        width: w,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 230,
                child: MyWaveClipper(),
              ),
              Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
                width: w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Wellcome",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                      ),
                    ),
                    Text(
                      "Sign into your account",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 10,
                                spreadRadius: 7,
                                offset: Offset(1, 1),
                                color: Colors.grey.withOpacity(0.2))
                          ]),
                      child: TextField(
                        controller: emailController,
                        style: TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "Email",
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1.0)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1.0)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 10,
                                spreadRadius: 7,
                                offset: Offset(1, 1),
                                color: Colors.grey.withOpacity(0.2))
                          ]),
                      child: TextField(
                        controller: passwordController,
                        obscureText: true,
                        style: TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "Password",
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1.0)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1.0)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Expanded(child: Container()),
                        Text(
                          "Forgot your Password?",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 70,
              ),
              GestureDetector(
                onTap: () {
                  AuthController.instance.login(emailController.text.trim(),
                      passwordController.text.trim());
                  
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
                      "Sign in",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: w * 0.2,
              ),
              RichText(
                text: TextSpan(
                  text: "Don\'t have an account?",
                  style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  children: [
                    TextSpan(
                        text: " Create",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Get.to(() => RegisterView()))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
