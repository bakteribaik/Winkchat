import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:snapmatch/ChatRooms/ChatRoom.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../PageCollection/Comment.dart';

class OtherProfile extends StatefulWidget {

  final String email_user;
  final String id_user;
  final String name_user;
  final String UserToken;
  final String UserGender;

  const OtherProfile({ Key? key, required this.id_user, required this.email_user, required this.name_user, required this.UserToken, required this.UserGender}) : super(key: key);

  @override
  State<OtherProfile> createState() => _OtherProfileState();
}

class _OtherProfileState extends State<OtherProfile> {

  bool isMe = false;

  String nama = '';

  final _user = FirebaseAuth.instance.currentUser;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  CollectionReference posting = FirebaseFirestore.instance.collection('posting');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.id_user == _user!.uid) {
      setState(() {
        isMe = true;
      });
    }else{
      setState(() {
        isMe = false;
      });
    }

    users
      .doc(_user!.email)
      .get()
      .then((value){
        var data = value.data() as Map<String, dynamic>;
        setState(() {
          nama = data['USERNAME'];
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 50),
          child: Column(
            children: [
                  Container(
                    child: FutureBuilder<DocumentSnapshot>(
                      future: users.doc(widget.email_user).get(),
                      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
                        if (snapshot.connectionState == ConnectionState.done) {
                          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                          var following = snapshot.data!.get('FOLLOWING') as List;
                          var follower = snapshot.data!.get('FOLLOWER') as List;

                          return Container(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Center(
                              child: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  CircleAvatar(backgroundColor: Colors.lightBlue[50], radius: 30),
                                  const SizedBox(height: 10,),                                              
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [                                          
                                      Text(data['USERNAME'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.lightBlue[300]),),                      

                                      const SizedBox(width: 3,),
                                      if(data['VERIFIED'] == true)
                                        const Image(image: AssetImage('assets/icons/verified_icon.png'), height: 15,)
                                      else
                                        const SizedBox(),                                                                                                                    
                                      
                                    ],
                                  ),
                                  const SizedBox(height: 5,),
                                  Text(data['BIO'], style: const TextStyle(fontSize: 14, color: Colors.grey),),
                                  const SizedBox(height: 3,),
                                  if (data['LINK'] != '')
                                    GestureDetector(
                                      onTap: () {
                                        launchUrl(Uri.parse(data['LINK']));
                                      },
                                      child: Container(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.link, color: Colors.blue[200], size: 17,),
                                            const SizedBox(width: 3,),
                                            Text(data['LINK'], style: TextStyle(color: Colors.blue[200], fontSize: 13),)
                                          ],
                                        ),
                                      ),
                                    )
                                  else
                                    const SizedBox(),
                                
                                  if(data['TIKTOK'] != '')
                                  Text('Social Media', style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold),)
                                  else 
                                  const SizedBox(),

                                  const SizedBox(height: 5,),
                                    if(data['TIKTOK'] != '')
                                      GestureDetector(
                                        onTap: (){
                                          if (data['TIKTOK'].toString().contains('http') || data['TIKTOK'].toString().contains('https')) {
                                            launchUrl(Uri.parse(data['TIKTOK']));
                                          }else{
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                backgroundColor: Colors.red[300],
                                                content: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: const [
                                                    Icon(Icons.tiktok_outlined, color: Colors.white,),
                                                    SizedBox(width: 5,),
                                                    Text('Url tiktok tidak valid!', textAlign: TextAlign.center,)
                                                  ],
                                                )
                                              )
                                            );
                                          }                                            
                                        },
                                        child: Container(                                    
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            border: Border.all(width: 1, color: Colors.grey),
                                            borderRadius: BorderRadius.circular(5)
                                          ),
                                          child: const Center(child: Icon(Icons.tiktok_outlined, color: Colors.grey,)),
                                        ),
                                      )
                                    else 
                                      const SizedBox(),   
                                  const SizedBox(height: 20,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        children: [
                                          Text(follower.length.toString(), style:  TextStyle(color: Colors.lightBlue[300])),                      
                                          Text('Followers', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink[200])), 
                                        ],
                                      ),
                                      const SizedBox(width: 100,),
                                      Column(
                                        children: [
                                          Text(following.length.toString(), style:  TextStyle(color: Colors.lightBlue[300])),                      
                                          Text('Following', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink[200])), 
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Center(child: CircularProgressIndicator(color: Colors.pink[200],),);
                      },
                    ),
                  ),


                 const SizedBox(height: 20,), //===============================


                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 15, top: 10, right: 20),
                      child: FutureBuilder<QuerySnapshot>(
                        future: posting.where('POST-AUTHOR-ID', isEqualTo: widget.id_user).orderBy('TIMESTAMP', descending: true).get(),
                        builder: (context, snapshot){
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator(color: Colors.pink[200]),);
                          }
                          return ListView(
                            children: snapshot.data!.docs.map((DocumentSnapshot document){
                              var data = document.data() as Map<String, dynamic>;
                              return Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container( //Header Postingan
                                      child: Row(
                                        children: [
                                          SizedBox(width: 10,),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      // Navigator.push(context, MaterialPageRoute(builder: (context) => OtherProfile(
                                                      //   name_user : data['USERNAME'],
                                                      //   id_user : data['POST-AUTHOR-ID'],
                                                      //   email_user : data['POST-AUTHOR-EMAIL'],
                                                      //   UserToken : data['USER-TOKEN'],
                                                      //   UserGender: data['GENDER'],
                                                      // )));
                                                    },
                                                    child: FutureBuilder<DocumentSnapshot>(
                                                      future: FirebaseFirestore.instance.collection('users').doc(data['POST-AUTHOR-EMAIL']).get(),
                                                      builder: (context, snapshot){
                                                        if(snapshot.connectionState == ConnectionState.waiting){
                                                          return const SizedBox();
                                                        }
                                                        Map<String, dynamic> data2 = snapshot.data!.data() as Map<String, dynamic>;
                                                        return Text(data2['USERNAME'], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.lightBlue[200]));
                                                      },
                                                    )
                                                  ),
                                                 
                                                  SizedBox(width: 3,),
                                                    if(data['VERIFIED'] == true)
                                                      const Image(image: AssetImage('assets/icons/verified_icon.png'), height: 15,)
                                                    else
                                                      const SizedBox(),  
                                                ],
                                              ),
                                              Text(timeago.format(DateTime.fromMillisecondsSinceEpoch(data['TIMESTAMP'])), style: TextStyle(color: Colors.grey,fontSize: 10),)
                                            ],
                                          ),
                                          Expanded(
                                            child: Container(                 
                                              alignment: Alignment.centerRight,
                                              width: MediaQuery.of(context).size.width,                      
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  GestureDetector(
                                                    onTap: (){

                                                    },
                                                    child: FaIcon(FontAwesomeIcons.ellipsisVertical, size: 15, color: Colors.grey,),
                                                  ),
                                                ],
                                              )
                                            ),
                                          )
                                        ],
                                      ),
                                    ),

                                    Container(
                                      margin: EdgeInsets.only(left: 10, top: 5),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(data['MESSAGE'],style: TextStyle(fontSize: 13, color: Colors.grey.shade700),),
                                        ],
                                      )
                                    ),

                                    Container(
                                        margin: EdgeInsets.only(left: 10, top: 5),        
                                        decoration: BoxDecoration(
                                          border: Border.all(width: 1, color: Colors.grey),
                                          borderRadius: BorderRadius.circular(10)
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [                          
                                              if(data['PICT_URL'] == '')
                                                SizedBox()
                                              else  
                                                Container(                        
                                                  height: 170,
                                                  width: MediaQuery.of(context).size.width/1.5,
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(9),
                                                    child: Image(image: NetworkImage(data['PICT_URL']), fit: BoxFit.cover,),
                                                  ),
                                                ),                           
                                          ],
                                        )
                                      ),

                                      SizedBox(height: 30,),

                                      Container(
                                        width: MediaQuery.of(context).size.width,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            StreamBuilder<QuerySnapshot>(
                                              stream: FirebaseFirestore.instance.collection('posting').doc(document.id).collection('commen').snapshots(),
                                              builder: (context, snapshot){
                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                        return  Text('0', style: TextStyle(color: Colors.grey[350]),);
                                                      }
                                                      return Text(snapshot.data!.docs.length.toString(), style: TextStyle(color: Colors.grey[350]),);
                                              }
                                            ),
                                            SizedBox(width: 5,),
                                            GestureDetector(
                                              onTap: (){
                                                showModalBottomSheet(                           
                                                  shape: const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))
                                                  ),
                                                  context: context, 
                                                  builder: (context){
                                                    return Comment(
                                                      author_id: data['POST-AUTHOR-ID'],
                                                      post_token : data['USER-TOKEN'],
                                                      post_id : data['POST-ID'],
                                                      name : data['USERNAME'],
                                                    );
                                                  }
                                                );
                                              },
                                              child: FaIcon(FontAwesomeIcons.comments, size: 18, color: Colors.grey[350],)
                                            ),
                                            SizedBox(width: 15,),
                                            
                                            StreamBuilder<DocumentSnapshot>(
                                              stream: FirebaseFirestore.instance.collection('posting').doc(document.id).snapshots(),
                                              builder: (context, snapshot){
                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                  return  Text('0', style: TextStyle(color: Colors.grey[350]),);
                                                }
                                                else if(snapshot.hasData){
                                                  var data = snapshot.data!.get('Z_LIKERS') as List;
                                                  return Text('${data.length}', style:  TextStyle(color: Colors.grey[350]),);
                                                }else{
                                                  return SizedBox();
                                                }
                                              }
                                            ),
                                            SizedBox(width: 5,),
                                            GestureDetector(
                                              onTap: (){
                                                posting
                                                  .doc(document.id)
                                                  .get()
                                                  .then((value){
                                                    var data = value.data() as Map<String, dynamic>;
                                                    if(data['Z_LIKERS'].toString().contains(_user!.uid)){
                                                      posting.doc(document.id).update({'Z_LIKERS' : FieldValue.arrayRemove([_user!.uid])});
                                                    }else{
                                                      posting.doc(document.id).update({'Z_LIKERS' : FieldValue.arrayUnion([_user!.uid])});
                                                    }
                                                  });
                                              },
                                              child: StreamBuilder<DocumentSnapshot>(
                                                stream: FirebaseFirestore.instance.collection('posting').doc(document.id).snapshots(),
                                                  builder: (context, snapshot){
                                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                                      return FaIcon(FontAwesomeIcons.heart, color: Colors.grey[300], size: 18);
                                                    }
                                                    if(snapshot.hasData){
                                                      var data = snapshot.data!.data() as Map<String, dynamic>;
                                                      return data['Z_LIKERS'].toString().contains(_user!.uid) == true ? FaIcon(FontAwesomeIcons.solidHeart, color: Colors.pink[300], size: 18) : FaIcon(FontAwesomeIcons.heart, color: Colors.grey[350], size: 18);
                                                    }else{
                                                      return SizedBox();
                                                    }
                                                  }
                                                ),
                                            )
                                          ],
                                        ),
                                      ),

                                    SizedBox(height: 10,),
                                    Divider(color: Colors.lightBlue[100])
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                      })
                    ),
                  )                
            ],
          ),
        )
      ),

      bottomNavigationBar: isMe ? const SizedBox() : Container(
        padding: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: (){    
                users
                  .doc(widget.email_user)
                  .get()
                  .then((value) async {
                    var data = value.data() as Map<String, dynamic>;
                    if (data['FOLLOWER'].toString().contains(_user!.uid)) {
                      users
                        .doc(widget.email_user)
                        .update({
                          'FOLLOWER' : FieldValue.arrayRemove([_user!.uid])
                        });
                      users
                        .doc(_user!.email)
                        .update({
                          'FOLLOWING' : FieldValue.arrayRemove([widget.id_user])
                        });    
                    }else{
                      users
                        .doc(widget.email_user)
                        .update({
                          'FOLLOWER' : FieldValue.arrayUnion([_user!.uid])
                        });
                      users
                        .doc(_user!.email)
                        .update({
                          'FOLLOWING' : FieldValue.arrayUnion([widget.id_user])
                        });
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
                                'title' : '$nama mulai mengikuti kamu 🎉'
                              },
                              'priority' : 'high',
                              'data' : <String, dynamic>{
                                'click_action' : 'FLUTTER_NOTIFICATION_CLICK',
                                'id' : '1',
                                'status' : 'done',
                              },
                              'to' : widget.UserToken
                            },
                          )
                        );
                      } catch (e) {
                        print(e.toString());
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text('Kamu mulai mengikuti ${widget.name_user}', textAlign: TextAlign.center,),
                        )
                      );
                    }
                  });                  
              },
              child: Container(
                width: MediaQuery.of(context).size.width/2.5,
                decoration: BoxDecoration(
                  color:  Colors.lightBlue[200],
                  borderRadius: BorderRadius.circular(15)
                ),
                child: StreamBuilder<DocumentSnapshot>(
                  stream: users.doc(widget.email_user).snapshots(),
                  builder: (context, snapshot){
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox();
                    }
                    var data = snapshot.data!.data() as Map<String, dynamic>;
                    return data['FOLLOWER'].toString().contains(_user!.uid) == false ? Center(child: Text('Follow', style: TextStyle(color: Colors.white))) : Center(child: Text('Unfollow', style: TextStyle(color: Colors.white)));
                  },
                )
              ),
            ),
            GestureDetector(
              onTap: (){       
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoom(
                  userName: widget.name_user,
                  userEmail : widget.email_user,
                  userID : widget.id_user,
                  Usertoken: widget.UserToken,
                  UserGender: widget.UserGender,
                )));
              },
              child: Container(
                width: MediaQuery.of(context).size.width/2.5,
                decoration: BoxDecoration(
                  color: Colors.pink[200],
                  borderRadius: BorderRadius.circular(15)
                ),
                child: const Center(child: Text('Chat', style: TextStyle(color: Colors.white),)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}