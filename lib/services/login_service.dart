import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:yogigg_users_app/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as json;

class LoginService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;
  String _verificationCode = "";
  int forceResendingToken;

  LoginService()
      : _firebaseAuth = FirebaseAuth.instance,
        _firestore = FirebaseFirestore.instance,
        _googleSignIn = GoogleSignIn();

  Future<User> getUser() async {
    var user = _firebaseAuth.currentUser;
    return user;
  }

  Future<bool> isSignedIn() async {
    final firebaseUser = _firebaseAuth.currentUser;
    return firebaseUser != null;
  }

  Future<User> signInWithEmailPassword(
      String email, String password) async {
    try {
      var authResult = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return authResult.user;
    } catch (error) {
      print(error.code);
      throw error;
    }
  }

  Future sendForgotPasswordLink(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw e;
    }
  }

  Future sendVerificationEmail(String uid) async {
    try {
      var user = _firebaseAuth.currentUser;
      await user.sendEmailVerification();
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<User> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      var authResult = await _firebaseAuth.signInWithCredential(credential);
      return authResult.user;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> sendOtp(
      String phoneNumber,
      Function(AuthCredential) onVerificationCompleted,
      Function(FirebaseAuthException) onVerificationFailed) async {
    print(phoneNumber);
    await _firebaseAuth
        .verifyPhoneNumber(
            phoneNumber: "+1" + phoneNumber,
            timeout: Duration(seconds: 60),
            verificationCompleted: (authCredential) =>
                onVerificationCompleted(authCredential),
            verificationFailed: onVerificationFailed,
            codeAutoRetrievalTimeout: (verificationId) =>
                _codeAutoRetrievalTimeout(verificationId),
            codeSent: (verificationId, [code]) =>
                _smsCodeSent(verificationId, [code]))
        .catchError((error) {
      print(error.code);
      throw error;
    });
  }

  Future<void> resendOtp(
      String phoneNumber,
      Function(AuthCredential) onVerificationCompleted,
      Function(FirebaseAuthException) onVerificationFailed) async {
    print(phoneNumber);
    await _firebaseAuth
        .verifyPhoneNumber(
            phoneNumber: "+1" + phoneNumber,
            forceResendingToken: forceResendingToken,
            timeout: Duration(seconds: 30),
            verificationCompleted: (authCredential) =>
                onVerificationCompleted(authCredential),
            verificationFailed: onVerificationFailed,
            codeAutoRetrievalTimeout: (verificationId) =>
                _codeAutoRetrievalTimeout(verificationId),
            codeSent: (verificationId, [code]) =>
                _smsCodeSent(verificationId, [code]))
        .catchError((error) {
      print(error.code);
      throw error;
    });
  }

  void _smsCodeSent(String verificationCode, List<int> code) {
    // set the verification code so that we can use it to log the user in
    this._verificationCode = verificationCode;
    forceResendingToken = code[0];
  }

  void _codeAutoRetrievalTimeout(String verificationCode) {
    // set the verification code so that we can use it to log the user in
    this._verificationCode = verificationCode;
  }

  Future<User> signInWithSmsCode(String smsCode) async {
    try {
      AuthCredential credential = PhoneAuthProvider.credential(
          smsCode: smsCode, verificationId: _verificationCode);

      var authResult = await _firebaseAuth.signInWithCredential(credential);
      return authResult.user;
    } catch (error) {
      print(error.code);
      throw error;
    }
  }

  Future<User> signInWithCredential(
      AuthCredential authCredential) async {
    try {
      var authResult = await _firebaseAuth.signInWithCredential(authCredential);
      return authResult.user;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<UserModel> signInWithFacebook() async {
    try {
      final facebookLogin = FacebookLogin();
      final result = await facebookLogin.logIn(['email', 'public_profile']);
      if (result.status == FacebookLoginStatus.loggedIn) {
        final graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${result.accessToken.token}');
        final profile = json.jsonDecode(graphResponse.body);
        print(profile);
        final AuthCredential fbAuthCredential =
            FacebookAuthProvider.credential(
                 result.accessToken.token);
        final authResult =
            await _firebaseAuth.signInWithCredential(fbAuthCredential);
        final user = UserModel.fromFirebaseUser(authResult.user);
        user.userEmail = profile['email'];
        user.firstName = profile['first_name'];
        user.lastName = profile['last_name'];
        return user;
      } else if (result.status == FacebookLoginStatus.cancelledByUser) {
        print(result.errorMessage);
        throw Exception('Login Cancelled');
      } else {
        print(result.errorMessage);
        throw Exception('Login Error');
      }
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<User> createUserAccount(String email, String password) async {
    try {
      var authResult = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      return authResult.user;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future signOut() async {
    await _firebaseAuth.signOut();
  }
}
