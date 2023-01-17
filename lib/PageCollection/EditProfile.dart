import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfile extends StatefulWidget {

  final String nickname;
  final String bio;
  final String link;
  final String tiktok;
  final String username;

  const EditProfile({
    Key? key,
    required this.nickname,
    required this.bio,
    required this.link,
    required this.tiktok,
    required this.username
  }) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {

  TextEditingController nicnameC = TextEditingController();
  TextEditingController bioC = TextEditingController();
  TextEditingController linkC = TextEditingController();
  TextEditingController tiktokC = TextEditingController();
  TextEditingController usernameC = TextEditingController();

  final _user = FirebaseAuth.instance.currentUser;
  CollectionReference user = FirebaseFirestore.instance.collection('users');
  late Future<DocumentSnapshot> _userFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _userFuture = user.doc(_user!.email).get();
    setState(() {
      nicnameC.text = widget.nickname;
      bioC.text = widget.bio;
      linkC.text = widget.link;
      tiktokC.text = widget.tiktok;
      usernameC.text = widget.username;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('Ubah Profil Kamu', style: TextStyle(color: Colors.grey, fontSize: 14),),
      ),
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot>(
          future: _userFuture,
          builder: (context, snapshot){
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox();
            }
            Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
            return Container(
              padding: const EdgeInsets.only(left: 10, right: 10),
              alignment: Alignment.center,
              child: Column(
                children: [

                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: TextField(
                      style: TextStyle(color: Colors.grey),
                      enabled: false,
                      autocorrect: false,                  
                      controller: usernameC,            
                      decoration: const InputDecoration(
                        label: Text('Username'),
                        hintText: 'Username',
                        border: InputBorder.none
                      ),
                    )
                  ), 

                  const SizedBox(height: 10,),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: TextField(   
                      enabled: true,
                      autocorrect: false,                  
                      controller: nicnameC,            
                      decoration: const InputDecoration(
                        label: Text('Nama'),
                        hintText: 'Nama Kamu',
                        border: InputBorder.none
                      ),
                    )
                  ), 

                  const SizedBox(height: 10,),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: TextField(             
                      maxLength: 30,         
                      autocorrect: false,
                      controller: bioC,
                      decoration: const InputDecoration(
                        label: Text('Bio'),
                        hintText: 'Bio',
                        border: InputBorder.none
                      ),
                    )
                  ), 

                  const SizedBox(height: 10,),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: TextField(
                      controller: linkC,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        label: Text('Custom Link'),
                        hintText: 'Link',
                        border: InputBorder.none
                      ),
                    )
                  ), 

                  const SizedBox(height: 10,),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: TextField(
                      controller: tiktokC,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        label: Text('Link Profile Tiktok'),
                        hintText: 'Contoh: https://vt.tiktok.com/ZSd4DA49T/',
                        border: InputBorder.none
                      ),
                    )
                  ), 

                  const SizedBox(height: 50,),
                  GestureDetector(
                    onTap: (){
                        user.doc(_user!.email).update({
                          'USERNAME' : nicnameC.text,
                          'BIO' : bioC.text,
                          'LINK' : linkC.text,
                          'TIKTOK' : tiktokC.text
                        })
                        .then((value){
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green[400],
                              content: const Text('Berhasil Update Profile, perlu refresh untuk beberapa perubahan', textAlign: TextAlign.center,),
                            )
                          );
                          Navigator.of(context).pop();
                        });                    
                    },
                    child: Container(                                    
                      height: 40,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(width: 1, color: Colors.grey),
                        borderRadius: BorderRadius.circular(5)
                      ),
                      child: const Center(child: Text('Simpan', style: TextStyle(color: Colors.grey),)),
                    ),
                  ),
                ],
              ),
            );
          },
        )
      ),
    );
  }
}