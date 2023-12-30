import 'package:get/get.dart';

import 'package:chat_app_firebase/app/modules/chat/chat_controller.dart';

class ChatRoomBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatRoomController>(
      () => ChatRoomController(),
    );
  }
}