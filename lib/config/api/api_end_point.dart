class ApiEndPoint {

  // Base URL =======================================
  static const String baseUrl = "http://10.10.7.7:5006/api/v1/";
  static const String imageUrl = "http://10.10.7.7:5006";
  static const String socketUrl = "http://10.10.7.46:5001";

  // Auth ===========================================
  static const String signUp = "${baseUrl}users/create-user";
  static const String signIn = "${baseUrl}auth/login";
  static const String verifyEmail = "${baseUrl}auth/verify-email";
  static const String forgotPassword = "${baseUrl}auth/request-otp";
  static const String verifyOtp = "${baseUrl}auth/verify-email";
  static const String resetPassword = "${baseUrl}auth/reset-password";
  static const String changePassword = "${baseUrl}auth/change-password";

  // User ===========================================
  static const String updateProfile = "${baseUrl}users/profile";
  static const String getProfile = "${baseUrl}users/profile";
  static const String getUserSingleProfileById = "${baseUrl}users/single/";
  static const String nearByUsers = "${baseUrl}users";

  // Post ===========================================
  static const String createPost = "${baseUrl}posts/create";
  static const String updatePost = "${baseUrl}posts/update/6968735eb38f9e7d204de36d";
  static const String getSinglePost = "${baseUrl}posts/single/";
  static const String getUserById = "${baseUrl}posts/user/";
  static const String getMyPost = "${baseUrl}posts/my-posts";
  static const String getAllPost = "${baseUrl}posts";

  // Friend =========================================
  static const String createFriendRequest = "${baseUrl}friend-requests/create/";
  static const String friendStatusUpdate = "${baseUrl}friend-requests/update/";
  static const String rejectedFriendRequest = "${baseUrl}friendships/";
  static const String getMyFriendRequest = "${baseUrl}friend-requests/my-requests";
  static const String getMyAllFriend = "${baseUrl}friendships/my-friends";
  static const String checkFriendStatus = "${baseUrl}/friendships/check/";

  // Chat ===========================================
  static const String createOneToOneChat = "${baseUrl}chats/create-1-to-1";
  static const String createChatGroup = "${baseUrl}chats/create-group";
  static const String deleteChatById = "${baseUrl}chats/696b6da6a27367444bc2403a";
  static const String leaveChat = "${baseUrl}chats/leave/696b6da6a27367444bc2403a";
  static const String joinChat = "${baseUrl}chats/join/696b6da6a27367444bc2403a";

  // Misc ===========================================
  static const String user = "${baseUrl}users";
  static const String post = "${baseUrl}posts";
  static const String customOffer = "${baseUrl}custom/offer";
  static const String profile = "${baseUrl}users/profile";
  static const String notifications = "${baseUrl}notification/all";
  static const String category = "${baseUrl}category/service";
  static const String privacyPolicies = "${baseUrl}disclaimer/privacy-policy";
  static const String termsOfServices = "${baseUrl}disclaimer/terms-and-conditions";
  static const String helpSupport = "${baseUrl}help/support";
  static const String chats = "${baseUrl}chats";
  static const String chatRoom = "${baseUrl}chat/room";
  static const String messages = "${baseUrl}messages";
  static const String servicePay = "${baseUrl}pay/booked-service";
  static const String myServiceHistory = "${baseUrl}pay/my-service-history";
  static const String updateRequest = "${baseUrl}pay/my-service-history/";

}
