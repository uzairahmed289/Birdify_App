import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class DashboardController extends GetxController {

  bool isDark = false;
  final box = GetStorage();

  changeTheme() {
    isDark = !isDark;
    update();
    print("Value - $isDark");
    Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
    box.write('isDarkMode', isDark);
    update();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    isDark = box.read("isDarkMode") ?? false;
    update();
  }
}