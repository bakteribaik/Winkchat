import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:snapmatch/HomePages/HomePage.dart';
import 'package:snapmatch/PageCollection/Banned.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({ Key? key }) : super(key: key);

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final _user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
      .collection('users')
      .doc(_user!.email)
      .get()
      .then((docs){
        var data = docs.data() as Map<String, dynamic>;
        if(data['BANNED'] == false) {
          Future.delayed(const Duration(milliseconds: 3500), (){        
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
          });
        }else{
          Future.delayed(const Duration(seconds: 1), (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BannedPage()));
          });
        }
      });  
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(child: Image(image: AssetImage('assets/gif/loading.gif'), height: 100,))
      ),
    );
  }
}