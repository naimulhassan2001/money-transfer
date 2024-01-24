import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_transfers/helper/shared_preference_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_route/app_route.dart';
import '../global/api_url.dart';
import '../services/api_services/api_services.dart';
import '../utils/app_utils.dart';

class ChangePasscodeController extends GetxController {
  RxBool disableKeyboard = false.obs;
  RxBool isLoading = false.obs;
  RxString passcodeToken = "".obs ;

  TextEditingController enterPasscodeController = TextEditingController();


  NetworkApiService networkApiService = NetworkApiService();
  SharedPreferenceHelper sharedPreferenceHelper = SharedPreferenceHelper() ;

  Future<void> getIsisLogIn() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();

      sharedPreferenceHelper.accessToken = pref.getString("accessToken") ?? "";
      sharedPreferenceHelper.isLogIn = pref.getBool("isLogIn") ?? false;
      print(
          "accessToken ====================================> ${sharedPreferenceHelper.accessToken.toString()}");

      changePasscodeRepo(sharedPreferenceHelper.accessToken);
    } catch (e) {
      print(e.toString());
    }
  }


  Future<void> changePasscodeRepo(String token) async {
    print("===================> changePasscodeRepo");
    isLoading.value = true;
    var body = {
      "passcode": enterPasscodeController.text,
    };
    print("===================>$body");

    Map<String, String> header = {'Authorization': "Bearer $token"};

    networkApiService
        .postApi(ApiUrl.verifyOldPasscode, body, header)
        .then((apiResponseModel) {
      isLoading.value = false;
      print(apiResponseModel.statusCode) ;
      print(apiResponseModel.message) ;
      print(apiResponseModel.responseJson) ;

      if (apiResponseModel.statusCode == 200) {
        var json = jsonDecode(apiResponseModel.responseJson);

        passcodeToken.value = json["data"]["passcodeToken"] ;

        print(passcodeToken) ;


        Get.toNamed(AppRoute.newPasscode);
      } else if (apiResponseModel.statusCode == 404) {
        Utils.toastMessage("passcode not match".tr);
      } else {
        Get.snackbar(
            apiResponseModel.statusCode.toString(), apiResponseModel.message);
      }
    });
  }

}
