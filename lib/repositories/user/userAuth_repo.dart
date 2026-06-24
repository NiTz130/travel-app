import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../models/user.dart';

/// Repository xử lý xác thực (Authentication) & thông tin người dùng
class UserAuthRepo {
  final auth.FirebaseAuth _firebaseAuth;

  UserAuthRepo({auth.FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? auth.FirebaseAuth.instance;

  /// Stream theo dõi trạng thái user thay đổi (VD: đăng nhập, đăng xuất)
  Stream<auth.User?> get onUserStateChanged => _firebaseAuth.userChanges();
  Stream<auth.User?> get onAuthStateChanged => _firebaseAuth.authStateChanges();

  /// Đăng ký tài khoản mới bằng email/password
  Future<List> signUp(
    String email,
    String userName,
    String password,
    String proPic,
  ) async {
    String authException = '';
    List signUpDetails = [];
    late auth.UserCredential userCredential;
    try {
      userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      authException = 'successful';
      signUpDetails = [
        {'user': userCredential.user, 'authException': authException},
      ];
      await createUser(
        userCredential.user!.uid,
        userCredential.user!.email ?? "",
        userName,
        proPic,
      );
    } on auth.FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        authException = 'Mật khẩu quá yếu';
      } else if (e.code == 'email-already-in-use') {
        authException = 'Email này đã được đăng ký';
      } else {
        authException = e.message ?? "Đăng ký thất bại";
      }
    } catch (e) {
      print(e);
    }
    return signUpDetails;
  }

  /// Kiểm tra email đã tồn tại trên hệ thống chưa
  Future<List> checkIfEmailInUse(String email) async {
    bool isFound = false;
    User? userDetails;
    List userState;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      isFound = true;
      userDetails = User.fromMap(querySnapshot.docs.first.data());
    }
    userState = [
      {'isFound': isFound, 'userDetails': userDetails},
    ];
    return userState;
  }

  /// Đăng nhập bằng email/password
  Future<List> signIn(String email, String password) async {
    bool isSignIn = true;
    String authException = '';
    List signInDetails = [];
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on auth.FirebaseAuthException catch (e) {
      isSignIn = false;
      if (e.code == 'user-not-found') {
        authException = 'Không tìm thấy tài khoản này';
      } else if (e.code == 'wrong-password') {
        authException = 'Sai mật khẩu';
      } else {
        authException = e.message ?? "Đăng nhập thất bại";
      }
    }
    signInDetails = [
      {'isSignIn': isSignIn, 'authException': authException},
    ];
    return signInDetails;
  }

  /// Gửi email xác thực tài khoản
  Future<void> emailVerification() async {
    await _firebaseAuth.currentUser?.sendEmailVerification();
  }

  /// Gửi email lấy lại mật khẩu
  Future<List> resetPassword(String email) async {
    String authException = '';
    bool isSend = false;
    List resetDetails = [];
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      isSend = true;
    } on auth.FirebaseAuthException catch (e) {
      isSend = false;
      if (e.code == 'invalid-email') {
        authException = 'Email không hợp lệ';
      } else {
        authException = e.message ?? "Lỗi gửi email";
      }
    }
    resetDetails = [
      {'isSend': isSend, 'authException': authException},
    ];
    return resetDetails;
  }

  /// Cập nhật tên hiển thị trên profile + cập nhật tên trong tất cả review
  Future<void> updateProfile(User user) async {
    try {
      await _firebaseAuth.currentUser?.updateDisplayName(user.name);
      // Update tên trong review của các attraction (nếu có)
      QuerySnapshot attractionsQuery = await FirebaseFirestore.instance
          .collection('attractions')
          .where('userIds', arrayContains: user.uid)
          .get();

      for (QueryDocumentSnapshot attractionDoc in attractionsQuery.docs) {
        List<dynamic> reviews = attractionDoc['reviews'];
        for (int i = 0; i < reviews.length; i++) {
          if (reviews[i]['userId'] == user.uid) {
            reviews[i]['name'] = user.name;
          }
        }
        await attractionDoc.reference.update({'reviews': reviews});
      }
    } catch (e) {
      print(e);
    }
  }

  /// Đăng nhập với Google
  Future<dynamic> signInWithGoogle() async {
    if (kDebugMode) {
      debugPrint('Google Sign-In is disabled for Firebase Emulator dev.');
      return null;
    }

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// Đăng xuất
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      print(e);
    }
  }

  /// Tạo mới document người dùng khi đăng ký thành công
  Future<void> createUser(
    String uid,
    String email,
    String userName,
    String proPic,
  ) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'uid': uid,
      'displayName': userName,
      'email': email,
      'proPic': proPic,
    });
  }
}

// Singleton dùng toàn app
final userAuthRep = UserAuthRepo();
