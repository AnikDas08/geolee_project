import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import '../controller/search_controller.dart';
import '../../../../features/message/data/model/search_friend_model.dart';

class SearchFriendScreen extends StatelessWidget {
  const SearchFriendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SearchFriendController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: CommonText(text: "Search Friend", fontWeight: FontWeight.w600, fontSize: 18.sp),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          children: [
            /// Search Bar
            TextField(
              controller: controller.searchController,
              onChanged: controller.onSearch,
              decoration: InputDecoration(
                hintText: "Search by name...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide.none),
              ),
            ),
            SizedBox(height: 20.h),

            /// User List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final list = controller.filteredUsers;
                if (list.isEmpty) {
                  return const Center(child: Text("No users found"));
                }

                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => Divider(height: 20.h, color: Colors.grey[100]),
                  itemBuilder: (context, index) {
                    final user = list[index];

                    return Row(
                      children: [
                        ClipOval(
                          child: CommonImage(
                            fill: BoxFit.fill,
                            imageSrc: "${ApiEndPoint.imageUrl}${user.image}",
                            height: 50.r, width: 50.r,
                          ),
                        ),
                        SizedBox(width: 15.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonText(text: user.name, fontWeight: FontWeight.w500, fontSize: 16.sp),
                              CommonText(text: "${user.distance?.toStringAsFixed(1)} km away", fontSize: 12.sp, color: Colors.grey),
                            ],
                          ),
                        ),

                        /// Action Button (Add / Cancel)
                        Obx(() {
                          if (user.friendStatus.value == FriendStatus.requested) {
                            return IconButton(
                              onPressed: () => controller.cancelRequest(user),
                              icon: Icon(Icons.person_remove_alt_1, color: Colors.orange, size: 28.sp),
                            );
                          } else {
                            return IconButton(
                              onPressed: () => controller.addFriend(user),
                              icon: Icon(Icons.person_add_alt_1, color: AppColors.primaryColor, size: 28.sp),
                            );
                          }
                        }),
                      ],
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}