class ApiEndPoint {
  static const String baseUrl = "http://148.230.126.149:5000/api/v1";
  static const String imageUrl = "http://148.230.126.149:5000";
  static const String socketUrl = "http://148.230.126.149:5000";
  //
  // static const String baseUrl = "http://10.10.7.7:5006/api/v1";
  // static const String imageUrl = "http://10.10.7.7:5006";
  // static const String socketUrl = "http://10.10.7.7:5006";

  // Auth ===========================================
  static const String signUp = "$baseUrl/users/create-user";
  static const String signIn = "$baseUrl/auth/login";
  static const String verifyEmail = "$baseUrl/auth/verify-email";
  static const String forgotPassword = "$baseUrl/auth/request-otp";
  static const String verifyOtp = "$baseUrl/auth/verify-email";
  static const String resetPassword = "$baseUrl/auth/reset-password";
  static const String changePassword = "$baseUrl/auth/change-password";

  // User ===========================================
  static const String updateProfile = "$baseUrl/users/profile";
  static const String getProfile = "$baseUrl/users/profile";
  static const String getUserSingleProfileById = "$baseUrl/users/single/";
  static const String nearByUsers = "$baseUrl/users";
  static const String deleteAccount = "$baseUrl/users/delete-account";
  static const String sendGreeting = "$baseUrl/chats/send-greetings";

  static String getMyChat(String search) {
    return "$baseUrl/chats/my-chats?searchTerm=$search&isGroupChat=false";
  }

  static const String createGroup = "$baseUrl/chats/create-group";
  static const String getPendingRequest="$baseUrl/join-requests/chat/";
  static const String createOneToOneChat = "$baseUrl/chats/create-1-to-1";

  // Post ===========================================
  static const String createPost = "$baseUrl/posts/create";
  static const String updatePost = "$baseUrl/posts/update/";
  static const String getSinglePost = "$baseUrl/posts/single/";
  static const String getUserById = "$baseUrl/posts/user/";
  static const String getMyPost = "$baseUrl/posts/my-posts";
  static const String getAllPost = "$baseUrl/posts";
  static const String deletePost = "$baseUrl/posts/delete/";

  // Friend =========================================
  static const String createFriendRequest = "$baseUrl/friend-requests/create/";
  static const String friendStatusUpdate = "$baseUrl/friend-requests/update/";
  static const String rejectedFriendRequest = "$baseUrl/friendships/";
  static const String getMyFriendRequest =
      "$baseUrl/friend-requests/my-requests";
  static const String getMyAllFriend = "$baseUrl/friendships/my-friends";
  static const String checkFriendStatus = "$baseUrl/friendships/check/";
  static const String cancelFriendRequest = "$baseUrl/friend-requests/update/";
  static const String unfriend = "$baseUrl/friendships/";
  static const String deleteFriend = "$baseUrl/friendships/";

  // Chat ===========================================
  // static const String createOneToOneChat = "$baseUrl/chats/create-1-to-1";
  static const String createChatGroup = "$baseUrl/chats/create-group";
  static String deleteChatById(String id) => "$baseUrl/chats/$id";
  static String leaveChat(String id) => "$baseUrl/chats/leave/$id";
  static String joinChat(String id) => "$baseUrl/chats/join/$id";
  static const String addMember = "$baseUrl/chats/add-member";
  static const String removeMember = "$baseUrl/chats/remove-member";
  static const String nearbyChat = "$baseUrl/users/";

  static const String createAds = "$baseUrl/advertisements/create";
  static const String getAdvertisementMe = "$baseUrl/advertisements/me";
  static const String getAdvertisementById = "$baseUrl/advertisements/single/";
  static const String updateAdvertisementById =
      "$baseUrl/advertisements/update/";
  static const String deleteAdvertisementById =
      "$baseUrl/advertisements/delete/";

  // Plan===============================================
  static const String getPlans = "$baseUrl/plans";

  //Advertiser========================================
  static const String advertiserCompleteProfile = "$baseUrl/advertisers/create";
  static const String advertiserVerify = "$baseUrl/advertisers/verify";
  static const String resendOtp = "$baseUrl/auth/request-otp";
  static const String advertisementsOverviewMe =
      "$baseUrl/advertisements/overview/me";
  static const String getsMyAdsByStatus = "$baseUrl/advertisements/me";
  static const String advertiserUpdate = "$baseUrl/advertisers/update/me";

  // Support ========================================
  static const String support = "$baseUrl/supports/create";

  // Misc ===========================================
  static const String user = "$baseUrl/users";
  static const String post = "$baseUrl/posts";
  static const String customOffer = "$baseUrl/custom/offer";
  static const String profile = "$baseUrl/users/profile";
  static const String advertiserProfile = "$baseUrl/advertisers/me";
  static const String notifications = "$baseUrl/notification/all";
  static const String category = "$baseUrl/category/service";
  static const String privacyPolicies = "$baseUrl/disclaimer/privacy-policy";
  static const String termsOfServices =
      "$baseUrl/disclaimer/terms-and-conditions";
  static const String helpSupport = "$baseUrl/help/support";
  static const String chats = "$baseUrl/chats";
  static const String chatRoom = "$baseUrl/chats/my-chats";
  static const String messages = "$baseUrl/messages/chat";
  static const String createMessage = "$baseUrl/messages/create";
  static const String servicePay = "$baseUrl/pay/booked-service";
  static const String myServiceHistory = "$baseUrl/pay/my-service-history";
  static const String updateRequest = "$baseUrl/pay/my-service-history/";
  static const String readAllNotification = "$baseUrl/notifications/read-all";
  static const String readNotificationById = "$baseUrl/notifications/read/";


  static String updateChatById(String chatId) => '$baseUrl/chats/update/$chatId';


}
