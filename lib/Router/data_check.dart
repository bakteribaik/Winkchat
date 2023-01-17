import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snapmatch/CreateUser/CreateUserPage.dart';
import 'package:snapmatch/Router/loading.dart';

import '../HomePages/HomePage.dart';
import '../PageCollection/Banned.dart';

class DataCheckPage extends StatefulWidget {
  const DataCheckPage({ Key? key }) : super(key: key);

  @override
  State<DataCheckPage> createState() => _DataCheckPageState();
}

class _DataCheckPageState extends State<DataCheckPage> {

 
  String token = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final _user = FirebaseAuth.instance.currentUser;
    FirebaseMessaging.instance.getToken().then((value){
      token = value.toString();
      print('TOKEN DIDAPATKAN: $token');
    });

    FirebaseFirestore.instance
      .collection('users')
      .doc(_user!.email)
      .get()
      .then((docs){
        if(docs.exists) {
           FirebaseFirestore.instance
            .collection('users')
            .doc(_user.email)
            .update({
              'USER-TOKEN' : token
            }).then((value){
              print('TOKEN USER DI UPDATE');
            });

          FirebaseFirestore.instance
            .collection('chats')
            .orderBy('users.${_user.uid}')
            .get()
            .then((QuerySnapshot snapshot){
                snapshot.docs.forEach((element) {
                  var data = element.data() as Map<String, dynamic>;
                  if (data['sender_id'] == _user.uid) {
                    FirebaseFirestore.instance
                      .collection('chats')
                      .doc(element.id)
                      .update({
                        'sender_token' : token
                      })
                      .then((value){
                        print('TOKEN DI CHAT DI UPDATE');
                      });
                  }else{
                    FirebaseFirestore.instance
                      .collection('chats')
                      .doc(element.id)
                      .update({
                        'receiver_token' : token
                      })
                      .then((value){
                        print('TOKEN DI CHAT DI UPDATE');
                      });
                  }
              });
            });

          FirebaseFirestore.instance
            .collection('posting')
            .where('POST-AUTHOR-ID', isEqualTo: _user.uid)
            .get()
            .then((value){
              value.docs.forEach((element) {
                var data = element.data();
                if (data['POST-AUTHOR-ID'] == _user.uid) {
                  FirebaseFirestore.instance
                    .collection('posting')
                    .doc(element.id)
                    .update({
                      'USER-TOKEN': token
                    })
                    .then((value){
                      print('TOKEN DI POSTINGAN BERHASIL DI UPDATE');
                    });
                }
              });    
          });

          Future.delayed(Duration.zero, (){
            FirebaseFirestore.instance
              .collection('users')
              .doc(_user.email)
              .get()
              .then((docs){
                var data = docs.data() as Map<String, dynamic>;
                if(data['BANNED'] == false) {
                  Future.delayed(const Duration(milliseconds: 2), (){        
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
                  });
                }else{
                  Future.delayed(const Duration(seconds: 1), (){
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BannedPage()));
                  });
                }
              });                       
          });
        }else{
          Future.delayed(const Duration(seconds: 1), (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CreateUserPage()));
          });
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Loading...', style: TextStyle(color: Colors.grey),),
      ),
    );
  }
}