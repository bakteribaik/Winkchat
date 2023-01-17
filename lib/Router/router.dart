import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:snapmatch/Login/LoginPage.dart';
import 'package:snapmatch/Router/data_check.dart';

class Routers extends StatefulWidget {
  const Routers({ Key? key }) : super(key: key);

  @override
  State<Routers> createState() => _RoutersState();
}

class _RoutersState extends State<Routers> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator());
          }else if(snapshot.hasData){
            return const DataCheckPage();
          }else if (snapshot.hasError) {
            return const Center(child: Text('Something Went Wrong!'));
          }else{
            return const LoginPages();
          }
        },
      ),
    );
  }
}