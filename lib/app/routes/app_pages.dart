import 'package:get/get.dart';

import 'package:chat_app_firebase/app/modules/chat/chat_view.dart';
import 'package:chat_app_firebase/app/modules/chat/chat_binding.dart';

import 'package:chat_app_firebase/app/modules/home/home_binding.dart';
import 'package:chat_app_firebase/app/modules/home/home_view.dart';
import 'package:chat_app_firebase/app/modules/search/search_binding.dart';
import 'package:chat_app_firebase/app/modules/search/search_view.dart';

import 'package:chat_app_firebase/app/modules/auth/login/login_binding.dart';
import 'package:chat_app_firebase/app/modules/auth/login/login_view.dart';

import 'package:chat_app_firebase/app/modules/auth/register/register_binding.dart';
import 'package:chat_app_firebase/app/modules/auth/register/register_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.CHAT_ROOM,
      page: () =>
          ChatRoomView(friendUid: ''), 
      binding: ChatRoomBinding(),
    ),
    GetPage(
      name: _Paths.SEARCH,
      page: () => SearchWidget(),
      binding: SearchBinding(),
    ),
  ];
}
