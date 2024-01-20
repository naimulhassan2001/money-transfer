import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:money_transfers/controller/personal_info_controller.dart';
import 'package:money_transfers/core/app_route/app_route.dart';
import 'package:money_transfers/helper/shared_preference_helper.dart';
import 'package:money_transfers/utils/app_colors.dart';
import 'package:money_transfers/utils/app_icons.dart';
import 'package:money_transfers/view/widgets/app_bar/custom_app_bar.dart';
import 'package:money_transfers/view/widgets/back/back.dart';
import 'package:money_transfers/view/widgets/image/custom_image.dart';
import 'package:money_transfers/view/widgets/text/custom_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileInfo extends StatefulWidget {
  const ProfileInfo({super.key});

  @override
  State<ProfileInfo> createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  PersonalInfoController personalInfoController =
      Get.put(PersonalInfoController());

  SharedPreferenceHelper sharedPreferenceHelper = SharedPreferenceHelper();

  @override
  void initState() {
    getIsisLogIn();
    // TODO: implement initState
    super.initState();
  }

  Future<void> getIsisLogIn() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();

      sharedPreferenceHelper.accessToken = pref.getString("accessToken") ?? "";
      sharedPreferenceHelper.id = pref.getString("id") ?? "";
      sharedPreferenceHelper.isLogIn = pref.getBool("isLogIn") ?? false;
      print(
          "Personal Info  ====================================> ${sharedPreferenceHelper.accessToken.toString()}");

      personalInfoController.userDetailsRepo(
          sharedPreferenceHelper.accessToken, sharedPreferenceHelper.id);
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return SafeArea(
      top: false,
      child: Scaffold(
          extendBody: true,
          backgroundColor: AppColors.background,
          appBar: CustomAppBar(appBarContent: Back(onTap: () => Get.back())),
          body: Obx(() => personalInfoController.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomText(
                              text: "Personal info".tr,
                              fontSize: 24.sp,
                              bottom: 42.h),
                          Container(
                            height: 75.h,
                            width: 75.w,
                            decoration: BoxDecoration(
                              color: AppColors.white50,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.primaryColor, width: 0.5.w),
                            ),
                            child: Center(
                              child: CustomText(
                                  text: personalInfoController
                                          .userDetailsModelInfo
                                          ?.data
                                          ?.attributes
                                          ?.fullName?[0] ??
                                      "",
                                  fontSize: 40.sp,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                          CustomText(
                            text: personalInfoController.userDetailsModelInfo
                                    ?.data?.attributes?.fullName ??
                                "",
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w400,
                            top: 16.h,
                            bottom: 42.h,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: "Mobile number".tr,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.black50,
                            bottom: 4.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                text: personalInfoController
                                        .userDetailsModelInfo
                                        ?.data
                                        ?.attributes
                                        ?.phoneNumber ??
                                    "",
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w400,
                              ),
                              GestureDetector(
                                  onTap: () =>
                                      Get.toNamed(AppRoute.changePhoneNumber),
                                  child: CustomImage(
                                      imageSrc: AppIcons.edit, size: 18.h))
                            ],
                          ),
                          SizedBox(height: 24.h),
                          CustomText(
                            text: "Email".tr,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.black50,
                            bottom: 4.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                text: personalInfoController
                                        .userDetailsModelInfo
                                        ?.data
                                        ?.attributes
                                        ?.email ??
                                    "",
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w400,
                              ),
                              GestureDetector(
                                  onTap: () => Get.toNamed(AppRoute.editEmail),
                                  child: CustomImage(
                                      imageSrc: AppIcons.edit, size: 18.h))
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ))),
    );
  }
}
