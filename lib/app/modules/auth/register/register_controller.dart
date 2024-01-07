import 'package:get/get.dart';

class RegisterController extends GetxController {
var isObscure = true.obs;

  void toggleObscure() {
    isObscure.toggle();
  }
  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}
  void increment() => count.value++;
}
