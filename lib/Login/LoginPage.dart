import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:snapmatch/Service/google_signin_service.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPages extends StatefulWidget {
  const LoginPages({ Key? key }) : super(key: key);

  @override
  State<LoginPages> createState() => _LoginPagesState();
}

class _LoginPagesState extends State<LoginPages> {

  String terms = '';
  bool agree = false;

  TextEditingController emailC = TextEditingController();
  TextEditingController passC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[300],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(image: AssetImage('assets/icons/launcher_icon.png'), height: 80,),
              SizedBox(height: 10,),
              Text('winkchat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white),),
              SizedBox(height: 10,),
              Text('temukan besti mu hanya di winkchat ;D', style: TextStyle(fontSize: 13, color: Colors.white),),
              SizedBox(height: 20,),

                Container(
                  width: MediaQuery.of(context).size.width/2,
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    controller: emailC,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(color: Colors.white)
                    ),
                  ),
                ),
                SizedBox(height: 19,),
                Container(
                  width: MediaQuery.of(context).size.width/2,
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    controller: passC,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(color: Colors.white)
                    ),
                  ),
                ),
                SizedBox(height: 19,),
                GestureDetector(
                  onTap: (){
                    if (agree == false) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text('Kamu harus setuju dengan T&C dari winkchat', textAlign: TextAlign.center,),
                        )
                      );
                    }else{
                      final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
                      provider.staticLogin(emailC.text, passC.text);
                    }
                  },
                  child: Container(
                    height: 45,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.lightBlue[50],
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Center(child: Text('Login', style: TextStyle(color: Colors.grey),)),
                  )
                ),        

              SizedBox(height: 20,),
              Divider(indent: 20, endIndent: 20, color: Colors.white),
              SizedBox(height: 20,),
              Text('atau lanjutkan dengan akun google', style: TextStyle(color: Colors.white, fontSize: 10),),
              SizedBox(height: 10,),
              GestureDetector(
                onTap: () async {
                  if (agree == false) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text('Kamu harus setuju dengan T&C dari winkchat', textAlign: TextAlign.center,),
                      )
                    );
                  }else{
                    final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
                    provider.googleLogin();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  height: 50,
                  width: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children:  [
                      FaIcon(FontAwesomeIcons.google, color: Colors.lightBlue[300],),
                      Text('|', style: TextStyle(color: Colors.lightBlue[300],)),
                      Text('Google', style: TextStyle(color: Colors.lightBlue[300],)),
                    ],
                  )
                ),
              ),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: agree, 
                    onChanged: (value){
                      setState(() {
                        agree = value!;
                      });
                    }
                  ),
                  SizedBox(width: 3,),
                  Text('Setuju dengan ', style: TextStyle(fontSize: 10, color: Colors.white),),
                  GestureDetector(
                    onTap: (){
                      launchUrl(Uri.parse('https://github.com/bakteribaik/snapmatch_policy/blob/main/privacy-policy.md'));
                    },
                    child: Text('Terms and Condition ', style: TextStyle(fontSize: 10, color: Colors.purple),)
                  ),
                  Text('dari winkchat', style: TextStyle(fontSize: 10, color: Colors.white),)
                ],
              ),
            ],
          )
        ),
      )
    );
  }
}