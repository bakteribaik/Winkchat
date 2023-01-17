
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:snapmatch/Service/google_signin_service.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({ Key? key }) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

  final _user = FirebaseAuth.instance.currentUser;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: ElevatedButton(
        onPressed: (){
          users
            .doc(_user!.email)
            .update({
              'STATUS' : 'OFFLINE'
            });
          final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
          provider.logout();
          Future.delayed(const Duration(seconds: 1),(){SystemNavigator.pop();});
          },
        child: const Text('Logout'),
      )),
    );
  }
}