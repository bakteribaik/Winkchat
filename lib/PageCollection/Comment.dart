import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:snapmatch/OtherProfile/OtherProfile.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:http/http.dart' as http;

class Comment extends StatefulWidget {

  final String post_id;
  final String author_id;
  final String post_token;
  final String name;

  const Comment({
    Key? key,
    required this.post_id,
    required this.name,
    required this.post_token,
    required this.author_id
  }) : super(key: key);

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {

  final _user = FirebaseAuth.instance.currentUser;
  CollectionReference posting = FirebaseFirestore.instance.collection('posting');
  TextEditingController controller = TextEditingController();

  String query = '';
  String nama = '';
  String gender = '';
  String token = '';
  bool verified = false;
  bool admin = false;
  bool moderator = false;

  late Stream<QuerySnapshot> _getComment;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _getComment  = posting.doc(widget.post_id).collection('commen').orderBy('TIMESTAMP', descending: false).snapshots();

    FirebaseFirestore.instance
      .collection('users')
      .doc(_user!.email)
      .get()
      .then((DocumentSnapshot data) {
        setState(() {
          nama = data["USERNAME"];
          gender = data['GENDER'];
          verified = data['VERIFIED'];
          admin = data['ADMIN'];
          moderator = data['MODERATOR'];
          token = data['USER-TOKEN'];
        });
      });
  }

  _sendComment(){
    if (controller.text.isNotEmpty) {
      posting.doc(widget.post_id)
        .collection('commen')
        .add({
          'COMMENT-ID' : '',
          'COMMENT-NAME' : nama,
          'COMMENT-USER-ID': _user!.uid,
          'COMMENT-USER-EMAIL': _user!.email,
          'COMMENT-GENDER' : gender,
          'VERIFIED' : verified,
          'ADMIN' : admin,
          'MODERATOR' : moderator,
          'TIMESTAMP' : DateTime.now().millisecondsSinceEpoch,
          'MESSAGE' : controller.text,
          'USER-TOKEN' : token
        })
        .then((value) async {
          value.update({
            'COMMENT-ID' : value.id
          });
          controller.clear();
          FocusScope.of(context).unfocus();

          //send notif
          if (widget.author_id == _user!.uid){
            print('tidak mengirim notif');
          }else{
            try {
              await http.post(
                Uri.parse('https://fcm.googleapis.com/fcm/send'),
                headers: <String, String>{
                  'Content-Type' : 'application/json',
                  'Authorization' : 'key=AAAAxCXuUkY:APA91bHsl0zyBC0ZzJCfhwfw4wZ9umjaMevQU_YmOUqAO4BbPyW62UsfP2CL3Ko44sU1cMeyoxxvbdBEl6ShbbtiZmFKzfY-aURXe8ctgvD2pHqfxraFPfV39Aa_9buva5nxDkVEJnlo'
                },
                body: jsonEncode(
                  <String, dynamic>{
                    'notification' : <String, dynamic>{                                                            
                      'title' : '${nama} berkomentar di postingan anda'
                    },
                    'priority' : 'high',
                    'data' : <String, dynamic>{
                      'click_action' : 'FLUTTER_NOTIFICATION_CLICK',
                      'id' : '1',
                      'status' : 'done',
                    },
                    'to' : widget.post_token
                  },
                )
              );
            } catch (e) {
              print(e.toString());
            }
          }
        });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[300],
          content: const Text('Tidak bisa mengirim pesan kosong', textAlign: TextAlign.center,)
        )
      );
    }
  }

  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 30,
        actions: [
          IconButton(onPressed: (){
            Navigator.of(context).pop();
          }, icon: const Icon(Icons.close, color: Colors.grey, size: 16,))
        ],
        leading: const Text(''),
        centerTitle: true,
        titleTextStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('posting').doc(widget.post_id).collection('commen').snapshots(),
              builder: (context, snapshot){
                if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text('0');
                      }
                      return Text(snapshot.data!.docs.length.toString(),);
              }
            ),
            const SizedBox(width: 5,),
            const Text('comments')
          ],
        ),
      ),
      body: Container(
          padding: const EdgeInsets.only(right: 10, top: 5),
          child: StreamBuilder<QuerySnapshot>(
            stream: _getComment,
            builder: (context, snapshot){
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color:Colors.pink[200]));
              }else if(snapshot.hasError){
                return const Text('something went wrong');
              }else if(snapshot.hasData){
                return ListView(
                  controller: scrollController,
                  children: snapshot.data!.docs.map((DocumentSnapshot document){
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    return ListTile(
                      contentPadding: EdgeInsets.only(left: 25, right: 10),
                      dense: true,
                      //leading: const CircleAvatar(backgroundImage: AssetImage('assets/icons/app_icon.png'), radius: 17),
                      title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [              
                              Row(                                
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => OtherProfile(
                                        name_user : data['COMMENT-NAME'],
                                        id_user : data['COMMENT-USER-ID'],
                                        email_user : data['COMMENT-USER-EMAIL'],
                                        UserToken: data['USER-TOKEN'],
                                        UserGender: data['COMMENT-GENDER'],
                                      )));
                                    },
                                    child: Text(data['COMMENT-NAME'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF8D8DAA)),),
                                  ),         

                                  //////////////////////////////////////////////// USER BADGE                                                                                                                                                                                                                                                
                                  // if(data['ADMIN'] == true)
                                  //   Container(       
                                  //     margin: const EdgeInsets.only(left: 3),                                                                 
                                  //     padding: const EdgeInsets.only(left: 5, right: 5, top: 1, bottom: 1),
                                  //     decoration: BoxDecoration(
                                  //       color: const Color(0xFF8D8DAA),
                                  //       borderRadius: BorderRadius.circular(10)
                                  //     ),
                                  //     child: const Center(
                                  //       child: Text('admin', style: TextStyle(fontSize: 9, color: Colors.white),),
                                  //     ),
                                  //   )
                                  // else
                                  //   const SizedBox(),
      
                                  // if(data['MODERATOR'] == true)
                                  //   Container(                       
                                  //     margin: const EdgeInsets.only(left: 3),                                                  
                                  //     padding: const EdgeInsets.only(left: 5, right: 5, top: 1, bottom: 1),
                                  //     decoration: BoxDecoration(
                                  //       color: const Color(0xFF8D8DAA),
                                  //       borderRadius: BorderRadius.circular(10)
                                  //     ),
                                  //     child: const Center(
                                  //       child: Text('mod', style: TextStyle(fontSize: 9, color: Colors.white),),
                                  //     ),
                                  //   )
                                  // else
                                  //   const SizedBox(),
                        
                                  if(data['VERIFIED'] == true)
                                    Container(
                                      margin: const EdgeInsets.only(left: 3),
                                      child: const Image(image: AssetImage('assets/icons/verified_icon.png'), height: 15,)
                                    )
                                  else
                                    const SizedBox(),                                                                                                                    
                                  
                                  // if(data['ADMIN'] == true)
                                  //   const SizedBox()
                                  // else
                                  //   if (data['COMMENT-GENDER'] == 'P') 
                                  //     Container(
                                  //       margin: const EdgeInsets.only(left: 3), 
                                  //       height: 10,
                                  //       width: 15,
                                  //       decoration: BoxDecoration(
                                  //         color: Colors.pink[100],
                                  //         borderRadius: BorderRadius.circular(10)
                                  //       ),
                                  //       child: const Center(
                                  //         child: Icon(Icons.female, size: 10, color: Colors.pink,),
                                  //       ),
                                  //     )
                                  //   else
                                  //   Container(
                                  //     margin: const EdgeInsets.only(left: 3), 
                                  //     height: 10,
                                  //     width: 15,
                                  //     decoration: BoxDecoration(
                                  //       color: Colors.blue[100],
                                  //       borderRadius: BorderRadius.circular(10)
                                  //     ),
                                  //     child: const Center(
                                  //       child: Icon(Icons.male, size: 10, color: Colors.blue,),
                                  //     ),
                                  //   ),                                                                                                                                                                             

                                  ////////////////////////////////// END OF USER BADGE

                                  // Container(
                                  //   padding: EdgeInsets.only(top: 1),
                                  //   height: 15,
                                  //   width: 20,
                                  //   decoration: BoxDecoration(
                                  //     color: Colors.blue[200],
                                  //     borderRadius: BorderRadius.circular(10)
                                  //   ),
                                  //   child: Center(
                                  //     child: Text(data['AGE'].toString(), style: TextStyle(color: Colors.white,fontSize: 10),),
                                  //   ),
                                  // ),
                                  const SizedBox(width: 4,),              
                                  Text(timeago.format(DateTime.fromMillisecondsSinceEpoch(data['TIMESTAMP']), locale: 'en_short'), style: const TextStyle(fontSize: 13, color: Colors.grey),),                
                                ],
                              ),                                                           
                            ],
                          ),
                      subtitle: Text(data['MESSAGE'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      trailing: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if(data['COMMENT-USER-ID'] == _user!.uid)
                              IconButton(
                                onPressed: () {                                                        
                                  posting.doc(widget.post_id).collection('commen')
                                    .doc(data['COMMENT-ID'])
                                    .delete();   
                                    setState(() {
                                      _getComment  = posting.doc(widget.post_id).collection('commen').orderBy('TIMESTAMP', descending: false).snapshots();
                                    });                                                                                      
                                },  
                                icon: const FaIcon(FontAwesomeIcons.trashCan, size: 13,))
                            else 
                              const SizedBox()
                          ],
                        ),
                      )
                    );
                  }).toList(),
                );
              }else{
                return const Text('Something went wrong');
              }             
            },
          ),
        ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom,),
        child: Container(
          padding: const EdgeInsets.all(5),
          color: Colors.grey[200],
          child: Container(
            padding: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10)
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  query = value;
                });
              },
              controller: controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Tulis Komentar',
                hintStyle: const TextStyle(fontSize: 13),
                suffixIcon: IconButton(
                  onPressed: (){_sendComment();},
                  icon: const Icon(Icons.send),
                )
              ),
            ),
          ),
        )
      )
    );
  }
}