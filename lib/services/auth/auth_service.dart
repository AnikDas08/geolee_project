import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Google Sign In Flow
  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);


      return {
        "userCredential": userCredential,
        "idToken": googleAuth.idToken, // Original Google ID Token
      };
    } catch (e) {
      Get.snackbar("Error", "Google Sign-In failed: $e");
      debugPrint("❌ Google Sign-In Error: $e");
      return null;
    }
  }

  /// Apple Sign In Flow
  static Future<Map<String, dynamic>?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],


        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: "com.justmetaverse.justclicker.signin",
          redirectUri: Uri.parse(
            "https://just-clicker-count.firebaseapp.com/__/auth/handler",
          ),
        ),
      );

      final OAuthCredential credential =
      OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      return {
        "userCredential": userCredential,
        "idToken": appleCredential.identityToken,
      };

    } catch (e) {
      debugPrint("❌ Apple Sign-In Error: $e");
      return null;
    }
  }
  /// Sign Out
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
