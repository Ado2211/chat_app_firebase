import 'package:get/get.dart';

import 'package:chat_app_firebase/app/modules/auth/login/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(
      () => LoginController(),
    );
  }
}
