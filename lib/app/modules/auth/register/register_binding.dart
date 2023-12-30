import 'package:chat_app_firebase/app/modules/auth/register/register_controller.dart';
import 'package:get/get.dart';


class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterController>(
      () => RegisterController(),
    );
  }
}
