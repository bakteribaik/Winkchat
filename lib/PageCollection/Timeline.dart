
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/modals.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:snapmatch/OtherProfile/OtherProfile.dart';
import 'package:snapmatch/PageCollection/Comment.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:focused_menu/focused_menu.dart';
import 'package:photo_view/photo_view.dart';
import 'package:http/http.dart' as http;

class UserTimeline extends StatefulWidget {
  const UserTimeline({ Key? key }) : super(key: key);

  @override
  State<UserTimeline> createState() => _UserTimelineState();
}

class _UserTimelineState extends State<UserTimeline> with AutomaticKeepAliveClientMixin<UserTimeline>{

  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async{
    // monitor network fetch
    await Future.delayed(const Duration(seconds: 1));
    _refreshController.refreshCompleted();
    _getData = posting.orderBy('TIMESTAMP', descending: true).get();
    setState(() {});
  }

  bool isLike = false;
  int like = 0;
  int commentCount = 0;
  String namaSaya = '';

  final _user = FirebaseAuth.instance.currentUser;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  CollectionReference posting = FirebaseFirestore.instance.collection('posting');
  CollectionReference comment = FirebaseFirestore.instance.collection('comment');
  CollectionReference laporan = FirebaseFirestore.instance.collection('laporan');

  late Future<QuerySnapshot> _getData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData = posting.orderBy('TIMESTAMP', descending: true).get();

    FirebaseFirestore.instance
      .collection('users')
      .doc(_user!.email)
      .get()
      .then((DocumentSnapshot data) {
        if (data.exists) {
          setState(() {
            namaSaya = data["USERNAME"];
            print(namaSaya);  
          });
        }
      });
      
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Text('Beranda', style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 35, 33, 59), fontWeight: FontWeight.bold),),
            Stack(
              children: [
                TextButton(
                  onPressed: (){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text('Coming soon 😁', textAlign: TextAlign.center,),
                      )
                    );
                  },
                  child: Text('Mengikuti', style: TextStyle(fontSize: 16, color: Color.fromARGB(127, 35, 33, 59), fontWeight: FontWeight.bold),),
                ),
                Positioned(
                  top: 13,
                  right: 78,
                  child: CircleAvatar(
                    maxRadius: 5,
                    backgroundColor: Colors.pink[300],
                  )
                )
              ],
            )
          ],
        )
      ),

      body: Container(
        padding: EdgeInsets.only(left: 16, right: 20),
        child: FutureBuilder<QuerySnapshot>(
          future: _getData,
          builder: (context, snapshot){
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox();
            }
            return SmartRefresher(
              controller: _refreshController,
              onRefresh: _onRefresh,
              enablePullDown: true,
              enablePullUp: false,
              child: ListView(
                physics: BouncingScrollPhysics(),
                children: snapshot.data!.docs.map((DocumentSnapshot document){
                  var data = document.data() as Map<String, dynamic>;
                  return Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container( //Header Postingan
                          child: Row(
                            children: [
                              CircleAvatar(backgroundColor: Colors.lightBlue[50], radius: 20,),
                              SizedBox(width: 10,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(                                
                                    children: [
                                      GestureDetector(
                                        onTap: () {                  
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => OtherProfile(
                                            name_user : data['USERNAME'],
                                            id_user : data['POST-AUTHOR-ID'],
                                            email_user : data['POST-AUTHOR-EMAIL'],
                                            UserToken : data['USER-TOKEN'],
                                            UserGender: data['GENDER'],
                                          )));
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

                                      StreamBuilder<DocumentSnapshot>(
                                        stream: FirebaseFirestore.instance.collection('users').doc(data['POST-AUTHOR-EMAIL']).snapshots(),
                                        builder: (context, snapshot){
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return SizedBox();
                                          }

                                          var data = snapshot.data!.data() as Map<String, dynamic>;
                                          return data['VERIFIED'] == true ?
                                            Image(image: AssetImage('assets/icons/verified_icon.png'), height: 14,)
                                          : SizedBox();
                                        },
                                      ),
                                      Text(' • ${timeago.format(DateTime.fromMillisecondsSinceEpoch(data['TIMESTAMP']))}', style: TextStyle(color: Colors.grey,fontSize: 10),)
                                    ],
                                  ),
                                   Text('@${data['USER-ID']}', style: TextStyle(color: Colors.grey,fontSize: 12),),
                                ],
                              ),
                              Expanded(
                                child: Container(                 
                                  alignment: Alignment.centerRight,
                                  width: MediaQuery.of(context).size.width,                      
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if(data['POST-AUTHOR-ID'] != _user!.uid)
                                        StreamBuilder<DocumentSnapshot>(
                                          stream: users.doc(data['POST-AUTHOR-EMAIL']).snapshots(),
                                          builder: (context, snapshot){
                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                              return SizedBox();
                                            }

                                            var data = snapshot.data!.data() as Map<String, dynamic>;
                                            return data['FOLLOWER'].toString().contains(_user!.uid) == true ?
                                              SizedBox() : 
                                              GestureDetector(
                                                onTap: () async {
                                                  users
                                                  .doc(document.get('POST-AUTHOR-EMAIL'))
                                                  .update({
                                                    'FOLLOWER' : FieldValue.arrayUnion([_user!.uid])
                                                  });

                                                  users
                                                  .doc(_user!.email)
                                                  .update({
                                                    'FOLLOWING' : FieldValue.arrayUnion([document.get('POST-AUTHOR-ID')])
                                                  });

                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      behavior: SnackBarBehavior.floating,
                                                      content: Text('Kamu mulai mengikuti ${document.get('USERNAME')}', textAlign: TextAlign.center,),
                                                    )
                                                  );

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
                                                            'title' : '$namaSaya mulai mengikuti kamu 🎉'
                                                          },
                                                          'priority' : 'high',
                                                          'data' : <String, dynamic>{
                                                            'click_action' : 'FLUTTER_NOTIFICATION_CLICK',
                                                            'id' : '1',
                                                            'status' : 'done',
                                                          },
                                                          'to' : document.get('USER-TOKEN')
                                                        },
                                                      )
                                                    );
                                                  } catch (e) {
                                                    print(e.toString());
                                                  }
                                                },
                                                child: Container(margin: EdgeInsets.only(right: 8),child: Text('Follow', style: TextStyle(fontSize: 12, color: Colors.lightBlue),)),
                                              );
                                          },
                                        )                               
                                      else 
                                        SizedBox(),

                                      IconButton(
                                        alignment: Alignment.centerRight,
                                        onPressed: (){
                                          showModalBottomSheet<dynamic>(
                                            backgroundColor: Colors.transparent,                                                                
                                            context: context, 
                                            builder: (context){
                                              return FractionallySizedBox(                                                            
                                                child: Container(
                                                  padding: const EdgeInsets.all(10),
                                                  decoration: const BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))
                                                  ),
                                                  child: Wrap(                                                                                                                                                    
                                                    direction: Axis.vertical,
                                                    runAlignment: WrapAlignment.center,
                                                    crossAxisAlignment: WrapCrossAlignment.center,
                                                    children: [                                                                                    
                                                      TextButton(onPressed: (){
                                                        laporan
                                                          .add({
                                                            'ID_POSTINGAN' : data['POST-ID'],
                                                            'ID_AUTHOR' : data['POST-AUTHOR-ID'],
                                                            'EMAIL_AUTHOR' : data['POST-AUTHOR-EMAIL'],
                                                            'ID_PELAPOR' : _user!.uid,
                                                            'EMAIL_PELAPOR': _user!.email,
                                                            'PESAN_POSTINGAN': data['MESSAGE'],
                                                          });
                                                        Navigator.of(context).pop();
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(
                                                            content: Text('Laporan anda akan ditindak lanjuti, trimakasih 🙏', textAlign: TextAlign.center,),
                                                          )
                                                        );
                                                      }, child: Text('Laporkan Postingan!', style: TextStyle(color: Colors.pink[300]),)),

                                                      TextButton(onPressed: (){
                                                        Navigator.of(context).pop();
                                                        showModalBottomSheet(
                                                          backgroundColor: Colors.transparent,
                                                          context: context, 
                                                          builder: (context){
                                                            return FractionallySizedBox(
                                                              child: Container(
                                                                padding: EdgeInsets.all(10),
                                                                decoration: BoxDecoration(
                                                                  color: Colors.white,
                                                                  borderRadius: BorderRadius.only(
                                                                    topLeft: Radius.circular(20),
                                                                    topRight: Radius.circular(20)
                                                                  )
                                                                ),
                                                                child: Wrap(
                                                                  direction: Axis.vertical,
                                                                  runAlignment: WrapAlignment.center,
                                                                  crossAxisAlignment: WrapCrossAlignment.center,
                                                                  children: [
                                                                    TextButton(
                                                                      onPressed: (){}, 
                                                                      child: Text('Block')
                                                                    ),
                                                                    TextButton(
                                                                      onPressed: (){}, 
                                                                      child: Text('Report')
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                        );
                                                      }, child: const Text('Block/Report', style: TextStyle(color: Color(0xFF8D8DAA)))),

                                                      TextButton(onPressed: (){
                                                        Navigator.push(context, MaterialPageRoute(builder: (context) => OtherProfile(
                                                          name_user : data['USERNAME'],
                                                          id_user : data['POST-AUTHOR-ID'],
                                                          email_user : data['POST-AUTHOR-EMAIL'],
                                                          UserToken : data['USER-TOKEN'],
                                                          UserGender: data['GENDER'],
                                                        )));
                                                      }, child: const Text('Lihat Profile', style: TextStyle(color: Color(0xFF8D8DAA)))),
                                                      
                                                      if(data['POST-AUTHOR-ID'] == _user!.uid)
                                                      TextButton(onPressed: (){
                                                        Navigator.of(context).pop();

                                                        showDialog(context: context, builder: (context){
                                                          return AlertDialog(
                                                            content: const Text('Apakah anda yakin ingin menghapus postingan ini?', style: TextStyle(color: Color(0xFF8D8DAA), fontSize: 14), textAlign: TextAlign.center,),
                                                            actions: [
                                                              TextButton(onPressed: (){Navigator.of(context).pop();}, child: const Text('Tidak', style: TextStyle(color: Color(0xFF8D8DAA)))),
                                                              TextButton(onPressed: (){
                                                                posting.doc(document.id).delete();
                                                                setState(() {
                                                                  _getData = _getData = posting.orderBy('TIMESTAMP', descending: true).get();
                                                                });
                                                                Navigator.of(context).pop();
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  SnackBar(
                                                                    backgroundColor: Colors.green[200],
                                                                    content: const Text('Berhasil Menghapus Postingan', textAlign: TextAlign.center)
                                                                  )
                                                                );
                                                              }, child: const Text('Ya',  style: TextStyle(color: Color(0xFF8D8DAA))))
                                                            ],
                                                          );
                                                        });
                                                        
                                                      }, child: const Text('Delete Postingan', style: TextStyle(color: Color(0xFF8D8DAA))))
                                                      else 
                                                      const SizedBox(),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }
                                          );
                                        }, icon: FaIcon(FontAwesomeIcons.ellipsisVertical, size: 15, color: Colors.grey[400],),)
                                    ],
                                  )
                                ),
                              )
                            ],
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(left: 50, top: 5),
                          //padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            //color: Colors.lightBlue[50],
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [                          
                              Text(data['MESSAGE'],style: TextStyle(fontSize: 13, color: Colors.grey.shade700),),                            
                            ],
                          )
                        ),

                        Container(
                          margin: EdgeInsets.only(left: 50, top: 5),        
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey.shade100),
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
                                    .then((value) async {
                                      var data = value.data() as Map<String, dynamic>;
                                      if(data['Z_LIKERS'].toString().contains(_user!.uid)){
                                        posting.doc(document.id).update({'Z_LIKERS' : FieldValue.arrayRemove([_user!.uid])});
                                      }else{
                                        posting.doc(document.id).update({'Z_LIKERS' : FieldValue.arrayUnion([_user!.uid])});

                                        if(data['POST-AUTHOR-ID'] != _user!.uid){ //kalau bukan postingan sendiri maka kirim notif ke yang punya postingan
                                          print('mengirim notif like');
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
                                                    'title' : '${namaSaya} menyukai postingan anda'
                                                  },
                                                  'priority' : 'high',
                                                  'data' : <String, dynamic>{
                                                    'click_action' : 'FLUTTER_NOTIFICATION_CLICK',
                                                    'id' : '1',
                                                    'status' : 'done',
                                                  },
                                                  'to' : document.get('USER-TOKEN')
                                                },
                                              )
                                            );
                                          } catch (e) {
                                            print(e.toString());
                                          }
                                        }
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
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}