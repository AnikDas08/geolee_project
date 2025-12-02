import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/utils/constants/app_colors.dart';

import '../controller/search_controller.dart';

class SearchFriendScreen extends StatelessWidget {
  const SearchFriendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// App Bar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: CommonText(
          text: "Search Friend",
          fontWeight: FontWeight.w600,
          fontSize: 18.sp,
          color: Colors.black,
        ),
        centerTitle: true,
      ),

      /// Body
      body: GetBuilder<SearchFriendController>(
        init: SearchFriendController(),
        builder: (controller) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              children: [
                /// Search TextField
                TextField(
                  controller: controller.searchController,
                  onChanged: (value) => controller.searchUsers(value),
                  decoration: InputDecoration(
                    hintText: "Arlene",
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[400],
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey[600],
                      size: 22.sp,
                    ),
                    suffixIcon: controller.searchQuery.isNotEmpty
                        ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.grey[600],
                        size: 20.sp,
                      ),
                      onPressed: () => controller.clearSearch(),
                    )
                        : null,
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(
                        color: AppColors.primaryColor,
                        width: 1,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                /// User List
                Expanded(
                  child: controller.isLoading
                      ? Center(child: CircularProgressIndicator())
                      : controller.filteredUsers.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 60.sp,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16.h),
                        CommonText(
                          text: "No users found",
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8.h),
                        CommonText(
                          text: "Try searching with different name",
                          fontSize: 14.sp,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  )
                      : ListView.separated(
                    itemCount: controller.filteredUsers.length,
                    separatorBuilder: (context, index) => SizedBox(height: 16.h),
                    itemBuilder: (context, index) {
                      final user = controller.filteredUsers[index];
                      return Container(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey[200]!,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            /// Profile Image
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24.r,
                                  child: ClipOval(
                                    child: CommonImage(
                                      imageSrc: user.image,
                                      //imageType: ImageType.network,
                                      height: 48.r,
                                      width: 48.r,
                                      //fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                CommonText(
                                  text: user.name,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16.sp,
                                  color: Colors.black,
                                ),
                              ],
                            ),

                            /// Friend Status Icon
                            !user.isFriend
                                ? GestureDetector(
                              onTap: () => controller.sendFriendRequest(user.id),
                              child: Icon(
                                Icons.person_add_outlined,
                                color: Colors.black,
                                size: 24.sp,
                              ),
                            )
                                : SizedBox(
                              width: 24.sp,
                              height: 24.sp,
                              child: Icon(
                                Icons.check_box,
                                color: Colors.green,
                                size: 24.sp,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}