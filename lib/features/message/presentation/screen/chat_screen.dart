import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/features/message/presentation/screen/create_group_screen.dart';
import 'package:giolee78/features/message/presentation/screen/group_message.dart';
import '../../../../../../config/route/app_routes.dart';
import '../../../../component/other_widgets/common_loader.dart';
import '../../../../component/text/common_text.dart';
import '../../../../services/api/api_service.dart';
import '../controller/chat_controller.dart';
import '../../data/model/chat_list_model.dart';
import '../../../../../../utils/enum/enum.dart';
import '../../../../../../utils/constants/app_string.dart';
import '../../../../../../utils/constants/app_colors.dart';
import '../widgets/chat_list_item.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final con = ChatController.instance;

  Future<void> _sendJoinRequest(String chatId) async {
    try {
      final response = await ApiService.post(
        
        "${ApiEndPoint.createJoinRequest}",
        body: {
          "chat":chatId
        }
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          "Request Sent",
          "Your join request has been sent",
          colorText: Colors.black,
        );
      } else {
        Get.snackbar("Error", response.message ?? "Failed to send request");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: PopScope(
        canPop: false,
        onPopInvoked: (didpop) {
          if (didpop) {
            Get.offAllNamed(AppRoutes.homeNav);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () async {
                Get.offAllNamed(AppRoutes.homeNav);
              },
            ),
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
                      final TabController tabController =
                          DefaultTabController.of(context);
                      if (tabController.index == 0) {
                        Get.toNamed(AppRoutes.searchScreen);
                      } else {
                        Get.to(() => const CreateGroupScreen());
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
                  final TabController tabController = DefaultTabController.of(
                    context,
                  );
                  return AnimatedBuilder(
                    animation: tabController,
                    builder: (context, _) {
                      Tab buildTab(String title, int index) {
                        final bool isSelected = tabController.index == index;
                        return Tab(
                          child: Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: 10.w),
                            decoration: ShapeDecoration(
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
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
                              color: isSelected ? Colors.white : Colors.black,
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

          body: GetBuilder<ChatController>(
            init: con,
            builder: (controller) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Column(
                  children: [
                    /// Search bar
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
                        suffixIcon:
                            controller.searchController.text.trim().isNotEmpty
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
                          borderSide: const BorderSide(
                            color: AppColors.primaryColor,
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
                          // ─── Chat Tab ───────────────────────────────
                          controller.isSingleLoading
                              ? const CommonLoader()
                              : controller.singleChats.isEmpty
                              ? SizedBox(
                                  height: Get.height,
                                  width: Get.width,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ListView.builder(
                            controller: controller.singleScrollController,
                            itemCount: controller.filteredSingleChats.length +
                                (controller.isLoadingMoreSingle ? 1 : 0),
                            padding: EdgeInsets.only(top: 16.h),
                            itemBuilder: (context, index) {
                              if (index == controller.filteredSingleChats.length) {
                                return Padding(
                                  padding: EdgeInsets.all(16.h),
                                  child: const Center(
                                    child: CircularProgressIndicator(color: AppColors.primaryColor),
                                  ),
                                );
                              }
                              final ChatModel item = controller.filteredSingleChats[index];
                              return GestureDetector(
                                onTap: () {
                                  Get.toNamed(
                                    AppRoutes.message,
                                    parameters: {
                                      "userId": item.participant.sId,
                                      "chatId": item.id,
                                      "name": item.isGroup
                                          ? (item.chatName ?? "Unnamed Group")
                                          : item.participant.fullName,
                                      "image": item.isGroup
                                          ? (item.chatImage ?? "")
                                          : item.participant.image,
                                    },
                                  );
                                },
                                child: chatListItem(item: item, isFriend: item.isFriend),
                              );
                            },
                          ),

                          // ─── Group Tab ──────────────────────────────
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
                            Status.completed =>
                              controller.filteredChats.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                            text:
                                                "Try searching with different keywords",
                                            fontSize: 14.sp,
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                controller: controller.scrollController,
                                itemCount: controller.filteredChats.length +
                                    (controller.isLoadingMore ? 1 : 0),
                                padding: EdgeInsets.only(top: 16.h),
                                itemBuilder: (context, index) {
                                  if (index == controller.filteredChats.length) {
                                    return Padding(
                                      padding: EdgeInsets.all(16.h),
                                      child: const Center(
                                        child: CircularProgressIndicator(color: AppColors.primaryColor),
                                      ),
                                    );
                                  }
                                  final ChatModel item = controller.filteredChats[index];
                                  return GestureDetector(
                                    onTap: () {
                                      if (!item.amIAParticipant) return;
                                      Get.to(
                                            () => const GroupMessageScreen(),
                                        arguments: {
                                          "chatId": item.id,
                                          "groupName": item.chatName ?? "Unnamed Group",
                                          "memberCount": item.memberCount,
                                          "image": item.chatImage ?? "",
                                        },
                                      );
                                    },
                                    child: chatListItem(
                                      item: item,
                                      onJoinTap: () => _sendJoinRequest(item.id),
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
      ),
    );
  }
}
