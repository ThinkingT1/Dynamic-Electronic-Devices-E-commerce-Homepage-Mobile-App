import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ecmobile/layouts/main_layout.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Save the user's email
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', user.email!);

        final userDoc = await FirebaseFirestore.instance
            .collection('customers')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          String randomCode = "KH${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}";

          final customerData = {
            "uid": user.uid,
            "fullName": user.displayName ?? "Người dùng Google",
            "customerCode": randomCode,
            "nickname": user.displayName,
            "email": user.email,
            "phoneNumber": user.phoneNumber ?? "",
            "gender": "Nam",
            "address": "Chưa cập nhật",
            "photoUrl": user.photoURL,
            "authMethod": "google",
            "membershipRank": "Đồng",
            "isStudent": false,
            "studentRequestStatus": "pending",
            "totalSpending": 0,
            "purchasedOrderCount": 0,
            "createdAt": FieldValue.serverTimestamp(),
          };

          await FirebaseFirestore.instance
              .collection('customers')
              .doc(user.uid)
              .set(customerData);
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đăng nhập Google thành công!')),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainLayout()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      print("Lỗi Google Sign In: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đăng nhập thất bại: $e')),
        );
      }
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    // Clear the saved email on sign out
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
  }
}
