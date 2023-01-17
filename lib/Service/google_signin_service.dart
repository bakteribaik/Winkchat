import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();

  GoogleSignInAccount? _user;

  GoogleSignInAccount get user => _user!;

  Future googleLogin() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if(googleUser == null) return;
      _user = googleUser;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken
      );

      await FirebaseAuth.instance.signInWithCredential(credential);          
    } on PlatformException catch (e) {
      print(e.toString());
    }
    notifyListeners();
  }

  Future staticLogin(String email, String password) async {
    try {
      final result = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      final _userStatic = result.user;
      print(_userStatic!.email);
      
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future logout()async{
    try{
      FirebaseMessaging.instance.deleteToken();
      FirebaseAuth.instance.signOut();
      await googleSignIn.disconnect();
    } catch (e){
      print(e.toString());
    }
  }
}