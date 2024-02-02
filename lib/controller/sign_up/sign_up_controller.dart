import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:money_transfers/models/sign_up_model.dart';
import 'package:money_transfers/utils/app_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_route/app_route.dart';
import '../../global/api_url.dart';
import '../../services/api_services/api_services.dart';

class SignUpController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isLoadingSignUpScreen = false.obs;
  SignUpModel? signUpModelInfo;

  RxBool isResend = false.obs;

  Duration duration = const Duration();
  Timer? timer;
  RxInt time = 60.obs;

  RxString countryCode  = "+7".obs ;
  RxString countryISO = "RU".obs ;


  TextEditingController nameController = TextEditingController();

  TextEditingController emailController = TextEditingController();

  TextEditingController numberController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  TextEditingController confirmPasswordController = TextEditingController();

  TextEditingController otpController = TextEditingController();

  NetworkApiService networkApiService = NetworkApiService();

  String? validatePassword(String value) {
    RegExp regex = RegExp(r'^(?=.*?[a-z])(?=.*?[0-9]).{8,}$');
    if (value.isEmpty) {
      return 'Please enter password'.tr;
    } else {
      if (!regex.hasMatch(value)) {
        return 'Enter valid password'.tr;
      } else {
        return null;
      }
    }
  }

  Future<void> signUpRepo() async {
    print("===================> signUpRepo");

    isLoadingSignUpScreen.value = true;

    var body = {
      "fullName": nameController.text,
      "email": emailController.text,
      "phoneNumber": numberController.text,
      "password": passwordController.text,
      "countryCode": countryCode.value,
      "countryISO": countryISO.value,
    };
    print("===================>$body");
    Map<String, String> header = {
      'Otp': 'OTP ',
    };

    SharedPreferences pref = await SharedPreferences.getInstance();

    networkApiService
        .postApi(ApiUrl.signUp, body, header)
        .then((apiResponseModel) {
      isLoadingSignUpScreen.value = false;
      print(apiResponseModel.responseJson) ;
      print(apiResponseModel.statusCode) ;
      if (apiResponseModel.statusCode == 200) {
        Get.toNamed(AppRoute.signUpOtp);
        pref.setString("email", emailController.text);

        duration = const Duration(seconds: 60);
        time.value = 60;
        startTime();
      } else if (apiResponseModel.statusCode == 201) {
        Get.toNamed(AppRoute.signUpOtp);
        duration = const Duration(seconds: 60);
        time.value = 60;
        startTime();
      } else if (apiResponseModel.statusCode == 409) {
        Utils.snackBarMessage("User already exists".tr, "if forgot your password please, reset your password".tr) ;
        Get.toNamed(AppRoute.forgotPassword) ;
      }else {
        Utils.snackBarMessage(
            apiResponseModel.statusCode.toString(), apiResponseModel.message);
      }
    });
  }



  Future<void> signUpAuthRepo() async {
    print("===================> signUpAuthRepo");

    isLoading.value = true;

    var body = {
      "fullName": nameController.text,
      "email": emailController.text,
      "phoneNumber": numberController.text,
      "password": passwordController.text,
      "countryCode": countryCode.value,
      "countryISO": countryISO.value,
    };
    print("===================>$body");
    Map<String, String> header = {
      'Otp': 'OTP ${otpController.text}',
    };

    networkApiService
        .postApi(ApiUrl.signUp, body, header)
        .then((apiResponseModel) {
      isLoading.value = false;

      if (apiResponseModel.statusCode == 200) {
        var json = jsonDecode(apiResponseModel.responseJson);
        signUpModelInfo = SignUpModel.fromJson(json);
        Get.toNamed(AppRoute.passCode);
        nameController.clear();
        emailController.clear();
        numberController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
      } else if (apiResponseModel.statusCode == 201) {
        var json = jsonDecode(apiResponseModel.responseJson);
        signUpModelInfo = SignUpModel.fromJson(json);
        Get.toNamed(AppRoute.passCode);
        nameController.clear();
        emailController.clear();
        numberController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
      } else if (apiResponseModel.statusCode == 401) {
        Utils.snackBarMessage("Error".tr, "OTP is invalid".tr);
      } else if (apiResponseModel.statusCode == 400) {
        Utils.snackBarMessage("Error".tr, "OTP is invalid".tr);
      } else {
        Utils.snackBarMessage(
            apiResponseModel.statusCode.toString(), apiResponseModel.message);
      }
    });
  }

  ///=============================> Send Again   < =============================

  startTime() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      const addSeconds = 1;
      final seconds = duration.inSeconds - addSeconds;
      duration = Duration(seconds: seconds);
      if (time.value != 0) {
        time.value = seconds;
      } else {
        isResend.value = true;
        timer?.cancel();
      }
    });
  }
}
