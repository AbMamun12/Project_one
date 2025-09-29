import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserData {
  final String uid;
  final String fullName;
  final String email;

  UserData({required this.uid, required this.fullName, required this.email});

  factory UserData.fromMap(String uid, Map<String, dynamic> data) {
    return UserData(
      uid: uid,
      fullName: data["fullName"] ?? "",
      email: data["email"] ?? "",
    );
  }
}

class AuthController {
  static UserData? userData;

  /// ইউজার ডাটা লোড করো
  static Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
      if (doc.exists) {
        userData = UserData.fromMap(user.uid, doc.data()!);
      }
    }
  }

  /// লগআউট
  static Future<void> clearUserData() async {
    await FirebaseAuth.instance.signOut();
    userData = null;
  }
}
