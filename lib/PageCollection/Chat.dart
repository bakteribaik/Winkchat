import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:snapmatch/ChatRooms/ChatRoom.dart';

class UserChat extends StatefulWidget {
  const UserChat({ Key? key }) : super(key: key);

  @override
  State<UserChat> createState() => _UserChatState();
}

class _UserChatState extends State<UserChat> with AutomaticKeepAliveClientMixin<UserChat> {

  final _user = FirebaseAuth.instance.currentUser;

  String nama = '';
  int unread = 0;
 
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    FirebaseFirestore.instance
      .collection('users')
      .doc(_user!.email)
      .get()
      .then((DocumentSnapshot data) {
          nama = data["USERNAME"];
      });  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: const Text('Chat', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 17),),
      ),
      body: SafeArea(
        child: Container(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('chats').orderBy('users.${_user!.uid}', descending: false).snapshots(),
            builder: (context, snapshot){
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(),);
              }
              else if(snapshot.data == null){
                return const Center(child: Text('Room Chat Kosong',style: TextStyle(color: Colors.grey),),);
              }
              else if(snapshot.hasData){
                return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document){
                  Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                  return ListTile(
                    minVerticalPadding: 5,                                  
                      onLongPress: (){
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
                                      Navigator.of(context).pop();

                                      showDialog(context: context, builder: (context){
                                        return AlertDialog(
                                          content: const Text('Apakah anda yakin ingin menghapus chat ini?\n\nchat ini juga akan hilang di layar lawan bicara anda', style: TextStyle(color: Color(0xFF8D8DAA), fontSize: 14), textAlign: TextAlign.center,),
                                          actions: [
                                            TextButton(onPressed: (){Navigator.of(context).pop();}, child: const Text('Tidak', style: TextStyle(color: Color(0xFF8D8DAA)))),
                                            TextButton(onPressed: (){
                                              FirebaseFirestore.instance.collection('chats').doc(document.id).delete();                 
                                              Navigator.of(context).pop();
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  backgroundColor: Colors.green[200],
                                                  content: const Text('Berhasil Menghapus Chat', textAlign: TextAlign.center)
                                                )
                                              );
                                            }, child: const Text('Ya',  style: TextStyle(color: Color(0xFF8D8DAA))))
                                          ],
                                        );
                                      });
                                      
                                    }, child: const Text('Delete Chat', style: TextStyle(color: Color(0xFF8D8DAA))))                    
                                  ],
                                ),
                              ),
                            );
                          }
                        );
                      },
                      onTap: (){
                        if (document.get('sender_id') != _user!.uid) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoom(
                              userName: document.get('sender_name'),
                              userEmail : document.get('sender_email'),
                              userID : document.get('sender_id'),
                              Usertoken: document.get('sender_token'),
                              UserGender: document.get('sender_gender'),
                            )));
                            FirebaseFirestore.instance
                              .collection('chats')
                              .doc(document.id)
                              .update({
                                'sender_unread' : 0                                       
                              });
                        }else{
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoom(
                            userName: document.get('receiver_name'),
                            userEmail : document.get('receiver_email'),
                            userID : document.get('receiver_id'),
                            Usertoken: document.get('receiver_token'),
                            UserGender: document.get('receiver_gender'),
                          )));
                          FirebaseFirestore.instance
                              .collection('chats')
                              .doc(document.id)
                              .update({
                                'receiver_unread' : 0           
                              });                 
                        }                       
                      },
                      leading: CircleAvatar(backgroundColor: Colors.lightBlue[100],),
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(document.get('sender_id') != _user!.uid ? data['sender_name'] : data['receiver_name'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8D8DAA), fontSize: 14),),
                          const SizedBox(width: 3,),
                          if(document.get('sender_id') != _user!.uid)
                            if (data['sender_gender'] == 'P') 
                              Container(
                                margin: const EdgeInsets.only(left: 3, top: 5), 
                                height: 10,
                                width: 15,
                                decoration: BoxDecoration(
                                  color: Colors.pink[100],
                                  borderRadius: BorderRadius.circular(10)
                                ),
                                child: const Center(
                                  child: Icon(Icons.female, size: 10, color: Colors.pink,),
                                ),
                              )
                            else
                            Container(
                              margin: const EdgeInsets.only(left: 3, top: 5), 
                              height: 10,
                              width: 15,
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(10)
                              ),
                              child: const Center(
                                child: Icon(Icons.male, size: 10, color: Colors.blue,),
                              ),
                            )
                          else
                            if (data['receiver_gender'] == 'P') 
                              Container(
                                margin: const EdgeInsets.only(left: 3, top: 5), 
                                height: 10,
                                width: 15,
                                decoration: BoxDecoration(
                                  color: Colors.pink[100],
                                  borderRadius: BorderRadius.circular(10)
                                ),
                                child: const Center(
                                  child: Icon(Icons.female, size: 10, color: Colors.pink,),
                                ),
                              )
                            else
                            Container(
                              margin: const EdgeInsets.only(left: 3, top: 5), 
                              height: 10,
                              width: 15,
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(10)
                              ),
                              child: const Center(
                                child: Icon(Icons.male, size: 10, color: Colors.blue,),
                              ),
                            ),
                          // StreamBuilder<DocumentSnapshot>(
                          //   stream: FirebaseFirestore.instance.collection('users').doc(document.get('sender_id') == _user!.uid ? data['receiver_email'] : data['sender_email']).snapshots(),
                          //   builder: (context, snapshot){
                          //     if(snapshot.connectionState == ConnectionState.waiting){
                          //       return const SizedBox();
                          //     }
                          //     data = snapshot.data!.data() as Map<String, dynamic>;
                          //     return Container(                
                          //       child: Column(
                          //         children: [
                          //           if(data['STATUS'] == 'ONLINE')
                          //           Container(
                          //             margin: const EdgeInsets.only(top: 3),
                          //             padding: const EdgeInsets.only(left: 5, right: 5, top: 1, bottom: 1),
                          //             decoration: BoxDecoration(
                          //               border: Border.all(width: 0.5, color: Colors.green),
                          //               borderRadius: BorderRadius.circular(30)
                          //             ),
                          //             child: const Text('online', style: TextStyle(fontSize: 8, color: Colors.green),),
                          //           )
                          //           else 
                          //           Container(
                          //             margin: const EdgeInsets.only(top: 3),                                      
                          //             padding: const EdgeInsets.only(left: 5, right: 5, top: 1, bottom: 1),
                          //             decoration: BoxDecoration(
                          //               border: Border.all(width: 0.5, color: Colors.red),
                          //               borderRadius: BorderRadius.circular(30)
                          //             ),
                          //             child: Text('offline', style: TextStyle(fontSize: 8, color: Colors.red[300]),),
                          //           )
                          //         ],
                          //       ),
                          //     );
                          //   },
                          // ),
                        ],
                      ),
                      subtitle: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if(data['last_message'] == '')
                             if(document.get('sender_id') == _user!.uid)
                              const Text('Kamu baru saja mengunjungi profilnya')
                             else 
                              const Text('Dia mengunjungi profilmu')
                            else
                              Text(data['last_message'] ?? '', overflow: TextOverflow.ellipsis,)
                          ],
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if(document.get('sender_id') != _user!.uid)
                            if(data['sender_unread'] == 0)
                              const SizedBox()
                            else 
                              CircleAvatar(
                                maxRadius: 9,
                                backgroundColor: Colors.red[100],
                                child: Container(
                                  margin: const EdgeInsets.only(top: 1),
                                  child: Text(data['sender_unread'] > 99 ? '99+' : data['sender_unread'].toString(), style: const TextStyle(fontSize: 10, color: Colors.red),)
                                )
                              )                                
                          else 
                            if(data['receiver_unread'] == 0)
                              const SizedBox()
                            else 
                              CircleAvatar(
                                maxRadius: 9,
                                backgroundColor: Colors.red[100],
                                child: Container(
                                  margin: const EdgeInsets.only(top: 1),
                                  child: Text(data['receiver_unread'] > 99 ? '99+' : data['receiver_unread'].toString(), style: const TextStyle(fontSize: 10, color: Colors.red),)
                                )
                              )    
                        ],
                      ),
                    );
                  }).toList(),
                );
              }
              else{
                return const Text('awdawdawd');
              }
            },
          )
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}