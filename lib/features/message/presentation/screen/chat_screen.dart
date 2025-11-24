import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/features/message/presentation/screen/create_group_screen.dart';
import 'package:giolee78/features/message/presentation/screen/group_message.dart';
import '../../../../../../config/route/app_routes.dart';
import '../../../../component/other_widgets/common_loader.dart';
import '../../../../component/text/common_text.dart';
import '../../../../component/text_field/common_text_field.dart';
import '../controller/chat_controller.dart';
import '../../data/model/chat_list_model.dart';
import '../../../../../../utils/enum/enum.dart';
import '../../../../../../utils/constants/app_string.dart';
import '../../../../../../utils/constants/app_colors.dart';
import '../widgets/chat_list_item.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        /// App Bar Section Starts here
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          leading: const SizedBox(),
          title: const CommonText(
            text: "Message",
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
          actions: [
            Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.add, color: Colors.black),
                  onPressed: () {
                    final TabController? tabController = DefaultTabController.of(context);
                    if (tabController != null) {
                      if (tabController.index == 0) {
                        // Chat tab is selected
                        Get.toNamed(AppRoutes.searchScreen);
                      } else {
                        // Group tab is selected
                        Get.to(() => CreateGroupScreen());
                      }
                    }
                  },
                );
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48.h),
            child: Builder(
              builder: (context) {
                final TabController? tabController = DefaultTabController.of(
                  context,
                );

                if (tabController == null) {
                  return const SizedBox.shrink();
                }

                return AnimatedBuilder(
                  animation: tabController,
                  builder: (context, _) {
                    Tab buildTab(String title, int index) {
                      final bool isSelected = tabController.index == index;
                      final Color bgColor = isSelected
                          ? AppColors.primaryColor
                          : Colors.transparent;
                      final Color textColor = isSelected
                          ? Colors.white
                          : Colors.black;

                      return Tab(
                        child: Container(
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(horizontal: 10.w),
                          decoration: ShapeDecoration(
                            color: bgColor,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                width: 1,
                                color: Color(0xFFBAC3C6),
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: CommonText(
                            text: title,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      );
                    }

                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 8.h,
                      ),
                      child: SizedBox(
                        height: 40.h,
                        child: TabBar(
                          controller: tabController,
                          indicatorPadding: EdgeInsets.zero,
                          labelPadding: EdgeInsets.zero,
                          indicatorColor: Colors.transparent,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.black,
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          tabs: [buildTab("Chat", 0), buildTab("Group", 1)],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),

        /// Body Section Starts here
        body: GetBuilder<ChatController>(
          init: ChatController(),
          builder: (controller) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Column(
                children: [
                  /// User Search bar here
                  TextField(
                    controller: controller.searchController,
                    onChanged: (value) => controller.searchChats(value),
                    decoration: InputDecoration(
                      hintText: AppString.search,
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

                  SizedBox(height: 12.h),

                  /// Tab Views
                  Expanded(
                    child: TabBarView(
                      children: [
                        /// Chat Tab
                        switch (controller.status) {
                          Status.loading => const CommonLoader(),
                          Status.error => SizedBox(
                            height: Get.height,
                            width: Get.width,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CommonImage(
                                    imageSrc: "assets/images/noData.png",
                                    height: 100.h,
                                    width: 100.w,
                                  ),
                                  SizedBox(height: 20.h),
                                  CommonText(
                                    text: "No Chat List Found",
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Status.completed => controller.filteredChats.isEmpty
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
                                  text: "No results found",
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8.h),
                                CommonText(
                                  text: "Try searching with different keywords",
                                  fontSize: 14.sp,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          )
                              : ListView.builder(
                            itemCount: controller.filteredChats.length,
                            padding: EdgeInsets.only(top: 16.h),
                            itemBuilder: (context, index) {
                              ChatModel item = controller.filteredChats[index];
                              return GestureDetector(
                                onTap: () {
                                  // Mark chat as seen before navigating
                                  controller.markChatAsSeen(item.id);

                                  Get.toNamed(
                                    AppRoutes.message,
                                    parameters: {
                                      "chatId": item.id,
                                      "name": item.participant.fullName,
                                      "image": item.participant.image,
                                    },
                                    arguments: {
                                      "chatId": item.id,
                                      "name": item.participant.fullName,
                                      "image": item.participant.image,
                                      "isActive": item.status,
                                    },
                                  );
                                },
                                child: chatListItem(
                                  item: item,
                                ),
                              );
                            },
                          ),
                        },

                        /// Group Tab (CORRECTED NAVIGATION HERE)
                        switch (controller.status) {
                          Status.loading => const CommonLoader(),
                          Status.error => SizedBox(
                            height: Get.height,
                            width: Get.width,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CommonImage(
                                    imageSrc: "assets/images/noData.png",
                                    height: 100.h,
                                    width: 100.w,
                                  ),
                                  SizedBox(height: 20.h),
                                  CommonText(
                                    text: "No Group List Found",
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Status.completed => controller.filteredChats.isEmpty
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
                                  text: "No results found",
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8.h),
                                CommonText(
                                  text: "Try searching with different keywords",
                                  fontSize: 14.sp,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          )
                              : ListView.builder(
                            itemCount: controller.filteredChats.length,
                            padding: EdgeInsets.only(top: 16.h),
                            itemBuilder: (context, index) {
                              ChatModel item = controller.filteredChats[index];
                              return GestureDetector(
                                onTap: () {
                                  // CORRECTED: Direct navigation to GroupMessageScreen
                                  Get.to(
                                        () => GroupMessageScreen(),
                                    arguments: {
                                      "chatId": item.id,
                                      "name": item.participant.fullName,
                                      "image": item.participant.image,
                                      "isActive": item.status,
                                    },
                                  );
                                },
                                child: chatListItem(
                                  item: item,
                                ),
                              );
                            },
                          ),
                        },
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}