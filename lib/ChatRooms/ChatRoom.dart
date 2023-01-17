import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Service/storage_services.dart';

class ChatRoom extends StatefulWidget {
  final  String userName;
  final String userEmail;
  final String userID;
  final String Usertoken;
  final String UserGender;

  const ChatRoom({
    Key? key,
    required this.userName,
    required this.userEmail,
    required this.userID,
    required this.Usertoken,
    required this.UserGender
    }) : super(key: key);

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom>{

  ScrollController Scontroller = ScrollController();

  String query = '';
  String nama = '';
  String gender = '';
  String token = '';
  String reply = '';
  TextEditingController controller = TextEditingController();
  CollectionReference chats = FirebaseFirestore.instance.collection('chats');
  final _user = FirebaseAuth.instance.currentUser;
  final CurrentUserID = FirebaseAuth.instance.currentUser!.uid;
  var ChatDocID;

  bool isMe = false;
  bool BukaHalaman = false;

  final Storage storage = Storage();

  String pict_url = '';
  File? image;
  String? ImagePath;
  String? FileName;

  Future _pickImageFromGallery() async {
    try {
      final image = await ImagePicker.platform.getImage(source: ImageSource.gallery, imageQuality: 30);

      if(image == null) return;

      final imageTemporary = File(image.path);
      setState(() {
        this.image = imageTemporary;
        this.ImagePath = image.path;
        this.FileName = image.name;
      });
    } on PlatformException catch (e) {
      print('Warning: $e');
    }
  }

  Future _pickImageFromCamera() async {
    try {
      final image = await ImagePicker.platform.getImage(source: ImageSource.camera, imageQuality: 30);

      if(image == null) return;

      final imageTemporary = File(image.path);
      setState(() {
        this.image = imageTemporary;
        this.ImagePath = image.path;
        this.FileName = image.name;
      });
    } on PlatformException catch (e) {
      print('Warning: $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    BukaHalaman = true;

    FirebaseFirestore.instance
      .collection('users')
      .doc(_user!.email)
      .get()
      .then((DocumentSnapshot data) {
        var document = data.data() as Map<String, dynamic>;
         setState(() {
            nama = document["USERNAME"];
            token = document['USER-TOKEN'];
            gender = document['GENDER'];

            print('Chatroom Name: $nama');
          });
      });

    Future.delayed(Duration(milliseconds: 100),(){
      chats
      .where('users', isEqualTo: {widget.userID : null, CurrentUserID : null})
      .limit(1)
      .get()
      .then((QuerySnapshot snapshot){
        if(snapshot.docs.isNotEmpty){
          setState(() {
            ChatDocID = snapshot.docs.single.id;
          });
        }else{
          chats 
            .add({  
              'sender_name'    : nama,
              'sender_id'      : _user!.uid,
              'sender_email'   : _user!.email,
              'sender_token'   : token,
              'sender_unread'  : 0,
              'sender_gender'  : gender,
              'sender_open'    : true, //rubah ke true jika sudah beli database

              'receiver_name'  : widget.userName,
              'receiver_id'    : widget.userID,
              'receiver_email' : widget.userEmail,
              'receiver_token' : widget.Usertoken,
              'receiver_unread': 0,
              'receiver_gender': widget.UserGender,
              'receiver_open'  : false,

              'last_message' : '',
              'users' : {widget.userID : null, CurrentUserID : null}
            })
            .then((value){
              setState(() {
                ChatDocID = value.id;
              });
            });
        }
      })
      .catchError((e){print(e.toString());});

       Timer.periodic(Duration(seconds: 1), (timer) { //cek jika halaman sedang dibuka
      //   print(BukaHalaman);
         if(BukaHalaman == true){
      //     chats
      //     .where('users', isEqualTo: {widget.userID : null, CurrentUserID : null})
      //     .limit(1)
      //     .get()
      //     .then((value){
      //       FirebaseFirestore.instance
      //         .collection('chats')
      //         .doc(value.docs.single.id)
      //         .collection('messages')
      //         .where('uid', isNotEqualTo: CurrentUserID)
      //         .get()
      //         .then((value){
      //           for (var element in value.docs) {
      //             FirebaseFirestore.instance
      //               .collection('chats')
      //               .doc(ChatDocID)
      //               .collection('messages')
      //               .doc(element.id)
      //               .update({                
      //                 'read' : true
      //               });
      //           }
      //         });
      //     });

          FirebaseFirestore.instance.collection('chats').doc(ChatDocID).snapshots().first
          .then((DocumentSnapshot document){
            var data = document.data() as Map<String, dynamic>;
            if (data['sender_id'] == CurrentUserID) {
              FirebaseFirestore.instance
              .collection('chats')
                .doc(ChatDocID)
                .update({
                  'sender_open' : true,               
                  //'receiver_unread' : 0                
                });
            } else {
              FirebaseFirestore.instance
                .collection('chats')
                .doc(ChatDocID)
                .update({
                  'receiver_open' : true,
                  //'sender_unread' : 0
                });
            }
          });
        }else{
          print('timer dimatikan');
          timer.cancel();

          FirebaseFirestore.instance.collection('chats').doc(ChatDocID).snapshots().first
          .then((DocumentSnapshot document){
            var data = document.data() as Map<String, dynamic>;
            if (data['sender_id'] == CurrentUserID) {
              FirebaseFirestore.instance
              .collection('chats')
                .doc(ChatDocID)
                .update({
                  'sender_open' : false,                                            
                });
            } else {
              FirebaseFirestore.instance
                .collection('chats')
                .doc(ChatDocID)
                .update({
                  'receiver_open' : false,  
                });
            }
          });
        }
      });
    });
  }

  _sendMessage(){
    if(controller.text.isEmpty && image != null){ // mengirim gambar saja
        FirebaseFirestore.instance.collection('chats').doc(ChatDocID).snapshots().first
            .then((DocumentSnapshot document){
              var data = document.data() as Map<String, dynamic>;
              if (data['sender_id'] == CurrentUserID) {
                FirebaseFirestore.instance
                .collection('chats')
                  .doc(ChatDocID)
                  .update({
                    'sender_unread' : FieldValue.increment(1)
                  });
              } else {
                FirebaseFirestore.instance
                  .collection('chats')
                  .doc(ChatDocID)
                  .update({
                    'receiver_unread' : FieldValue.increment(1)
                  });
              }
            });

          FirebaseFirestore.instance 
          .collection('chats')
          .doc(ChatDocID)
          .update({ 
              'last_message' : 'Mengirim Gambar'
          });

          FirebaseFirestore.instance 
            .collection('chats')
            .doc(ChatDocID)
            .collection('messages')
            .add({
              'read' : false,
              'reply' : reply,
              'message_id' : '',
              'pict' : pict_url,
              'timestamp' : DateTime.now().millisecondsSinceEpoch,
              'server_timestamp' : FieldValue.serverTimestamp(),
              'message' : '',
              'uid' : CurrentUserID
            })
            .then((value){
              value.update({
                'message_id' : value.id
              });          
            });
          _sendPushNotif(nama, controller.text);
          controller.clear();
          reply = '';
          ScaffoldMessenger.of(context).hideCurrentSnackBar();  

      }else{ //mengirim pesan bergambar
        if (controller.text.isNotEmpty && !controller.text.startsWith(' ')) {
          FirebaseFirestore.instance.collection('chats').doc(ChatDocID).snapshots().first
            .then((DocumentSnapshot document){
              var data = document.data() as Map<String, dynamic>;
              if (data['sender_id'] == CurrentUserID) {
                FirebaseFirestore.instance
                .collection('chats')
                  .doc(ChatDocID)
                  .update({
                    'sender_unread' : FieldValue.increment(1)
                  });
              } else {
                FirebaseFirestore.instance
                  .collection('chats')
                  .doc(ChatDocID)
                  .update({
                    'receiver_unread' : FieldValue.increment(1)
                  });
              }
            });

          FirebaseFirestore.instance 
          .collection('chats')
          .doc(ChatDocID)
          .update({ 
              'last_message' : controller.text
          });

          FirebaseFirestore.instance 
            .collection('chats')
            .doc(ChatDocID)
            .collection('messages')
            .add({
              'read' : false,
              'reply' : reply,
              'message_id' : '',
              'pict' : pict_url,
              'timestamp' : DateTime.now().millisecondsSinceEpoch,
              'server_timestamp' : FieldValue.serverTimestamp(),
              'message' : controller.text != null ? controller.text : '',
              'uid' : CurrentUserID
            })
            .then((value){
              value.update({
                'message_id' : value.id
              });          
            });
          _sendPushNotif(nama, controller.text);
          controller.clear();
          reply = '';
          ScaffoldMessenger.of(context).hideCurrentSnackBar();  
        }
      }
  }

  _sendPushNotif(nama, pesan) async {
    FirebaseFirestore.instance.collection('chats').doc(ChatDocID).snapshots().first
        .then((DocumentSnapshot document) async {
          var data = document.data() as Map<String, dynamic>;
           if (data['sender_id'] == CurrentUserID  &&  data['receiver_open'] == true) {
            print('tidak  mengirim notifikasi ke penerima');
          } else if (data['sender_id'] != CurrentUserID && data['sender_open'] == true) {
            print('tidak mengirim notifikasi ke pengirim');
          }else{
            print('pengirim notif $nama');
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
                      'body' : pesan == '' ? 'Mengirimkan Gambar' : pesan,
                      'title' : nama
                    },
                    'priority' : 'high',
                    'data' : <String, dynamic>{
                      'click_action' : 'FLUTTER_NOTIFICATION_CLICK',
                      'id' : '1',
                      'status' : 'done',
                    },
                    'to' : widget.Usertoken
                  },
                )
              );
            } catch (e) {
              print(e.toString());
            }
          }
        });    
    }

  

    @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    print('keluar halaman');
    BukaHalaman = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 233, 245, 252),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(widget.userName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.lightBlue),),
            SizedBox(width: 5,),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(widget.userEmail).snapshots(),
              builder: (context, snapshot){
                if(snapshot.connectionState == ConnectionState.waiting){
                  return const SizedBox();
                }
                var data = snapshot.data!.data() as Map<String, dynamic>;
                return Container(                
                  child: Column(
                    children: [
                      if(data['STATUS'] == 'ONLINE')
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.green,
                              radius: 3,
                            ),
                            SizedBox(width: 5,),
                            Text('online', style: TextStyle(fontSize: 10, color: Colors.green),),
                          ],
                        )
                      else 
                      Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: 3,
                            ),
                            SizedBox(width: 5,),
                            Text('offline', style: TextStyle(fontSize: 10, color: Colors.red),),
                          ],
                        )
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        // actions: [
        //   IconButton(
        //     onPressed: () async {            
        //       await start();
        //       ScaffoldMessenger.of(context).showMaterialBanner(
        //         MaterialBanner(
        //           backgroundColor: Color.fromARGB(255, 212, 212, 253),
        //           content: StreamBuilder<RecordingDisposition>(
        //             stream: recorder.onProgress,
        //             builder: (context, snapshot){
        //               final duration = snapshot.hasData ?
        //                 snapshot.data!.duration
        //                 : Duration.zero;

        //               String twoDigit(int n) => n.toString().padLeft(2,'0');
        //               final minute = twoDigit(duration.inMinutes.remainder(60));
        //               final second = twoDigit(duration.inSeconds.remainder(60));
                      
        //               return Text('Recording $minute:$second');
        //             },
        //           ),
        //           actions: [
        //             TextButton(onPressed: () async { 
        //               await stop();
        //               ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
        //             }, child: Text('Stop'))
        //           ]
        //         )
        //       );
        //     }, 
        //     icon: Icon(recorder.isRecording ? Icons.stop : Icons.mic, color: Colors.grey,))
        // ],
      ),
      body: Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('chats').doc(ChatDocID).collection('messages').limit(15).orderBy('server_timestamp', descending: true).snapshots(),
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return Center(child: Text('Loading..'),);
            }
            return ListView(
              controller: Scontroller,
              physics: BouncingScrollPhysics(),
              reverse: true,
              children: snapshot.data!.docs.map((DocumentSnapshot document){
                var data = document.data() as Map<String, dynamic>;
                var id = data['uid'];

                return FocusedMenuHolder(
                  onPressed: (){},
                  menuOffset: 20,
                  openWithTap: false,
                  menuItems: [
                    if(data['uid'] != CurrentUserID)
                    FocusedMenuItem(title: const Text('Balas'), onPressed: (){
                      reply = document['message'];
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(                                  
                          content: Text('Balas: ${document['message']}', style: const TextStyle(color: Color.fromARGB(255, 126, 126, 145)), overflow: TextOverflow.ellipsis,), backgroundColor: const Color.fromARGB(255, 214, 214, 243),
                          duration: const Duration(days: 99),
                          action: SnackBarAction(
                            label: 'Batal',
                            textColor: const Color.fromARGB(255, 126, 126, 145),
                            onPressed: (){
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              reply = '';
                            },
                          ),                             
                        )
                      );
                    }),
              
                    FocusedMenuItem(title: const Text('Salin Pesan'), onPressed: (){                              
                      Clipboard.setData(ClipboardData(text: document['message'])).then((value){                                 
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Berhasil menyalin pesan', textAlign: TextAlign.center,), backgroundColor: Colors.green,)
                        );
                      });
                    }),
                    if(data['uid'] == CurrentUserID) 
                    FocusedMenuItem(title: const Text('Tarik Pesan'), onPressed: (){
                      FirebaseFirestore.instance.collection('chats').doc(ChatDocID).collection('messages').doc(document.id).update({'message' : '⨂ Pesan Ditarik', 'pict' : ''});
                      FirebaseFirestore.instance.collection('chats').doc(ChatDocID).update({'last_message' : '⨂ Pesan Ditarik'});
                    })
                    else 
                    FocusedMenuItem(title: const Text('Close'), onPressed: (){})
                  ], 
                  child: Container(
                    padding:  id == CurrentUserID ? EdgeInsets.only(left: 50) : EdgeInsets.only(right: 50),
                    child: Column(
                      crossAxisAlignment: id == CurrentUserID ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 10, top: 10),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: id == CurrentUserID ? Colors.lightBlue[300] : Colors.white,
                            borderRadius: id == CurrentUserID ?  BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(20)) : BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomRight: Radius.circular(20))
                          ),
                          child: Column(
                            crossAxisAlignment: id == CurrentUserID ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              if(data['reply'] != '')                    
                                Container(
                                  padding: EdgeInsets.only(left: 5),
                                  alignment: Alignment.centerLeft,                    
                                  width: 200,
                                  decoration: BoxDecoration(
                                    border: Border(left: BorderSide(width: 2, color: Colors.lightBlue.shade50))
                                  ),                               
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if(id == CurrentUserID)
                                        Text(widget.userName, style: TextStyle(color: id == CurrentUserID ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),)
                                      else 
                                        Text(nama, style: TextStyle(color: id == CurrentUserID ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),),

                                      Text(data['reply'], style: TextStyle(color: id == CurrentUserID ? Colors.white : Colors.grey,  fontSize: 12), overflow: TextOverflow.ellipsis,),
                                    ],
                                  )
                                )
                              else 
                                SizedBox(),

                              if(data['pict'] != '')
                                Container(
                                  margin: EdgeInsets.only(bottom: 5, top: 5),
                                  height: 150,
                                  width: MediaQuery.of(context).size.width/2,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image(image: NetworkImage(data['pict']), height: 200, fit: BoxFit.cover,),
                                  ),
                                )
                              else 
                                SizedBox(),

                              if(data['message'] != '')
                                Text(data['message'], style: TextStyle(color: id == CurrentUserID ? Colors.white : Colors.grey[600], fontSize: 14,))
                              else 
                                SizedBox(),

                              Text('${DateFormat('kk:mm').format(DateTime.fromMillisecondsSinceEpoch(data['timestamp']))}', style: TextStyle(color: id == CurrentUserID ? Color.fromARGB(115, 255, 255, 255) : Colors.grey, fontSize: 12),)
                            ],
                          )
                        ),
                      ],
                    ),
                  ),
                );
              })
              .toList(),
            );
          },
        )
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom,),
        child: Container(
          padding: const EdgeInsets.only(left:10, right: 10, top: 5),
          decoration: const BoxDecoration(
            color: Colors.white
          ),
          child: TextField(    
            minLines: 1,                
            maxLength: 1000,
            maxLines: 2,                  
            keyboardType: TextInputType.multiline,
            autofocus: false,
            controller: controller,                
            decoration: InputDecoration( 
              counterText: '', 
              border: InputBorder.none,
              hintText: 'Tuliskan Pesan',                    
              suffixIcon: IconButton(                        
                onPressed: (){
                  if (image != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Mengirim gambar', textAlign: TextAlign.center,), behavior: SnackBarBehavior.floating, backgroundColor: Color(0xFF8D8DAA),)                            
                    );
                    storage.uploadFile(image!.path.toString(), FileName.toString()).whenComplete(() async {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      final firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;
                      final url = await storage.ref('post_pict/$FileName').getDownloadURL();

                      if (url.isNotEmpty) {
                        setState(() {
                          pict_url = url.toString();
                        });
                      }

                      _sendMessage();


                      setState(() {
                        image = null;
                        pict_url = '';
                      });                              
                    });
                  }else{
                    _sendMessage();
                  }                                                     
                },
                icon: Icon(Icons.send, size: 20),
              ),
              prefixIcon : image != null ?                       
              
              GestureDetector(
                onTap: (){
                  print('cancel');
                  setState(() {
                    image = null;
                    pict_url = '';
                  });
                },
                child: Container(
                  padding: EdgeInsets.only(right: 10),
                  height: 50,
                  width: 20,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(width: 3, color: Colors.pink.shade300)
                    )
                  ),
                  child: ClipRRect(                                                        
                    child: Image.file(image!, fit: BoxFit.cover,),
                  ),
                ),
              )       
              
              : IconButton(
                padding: const EdgeInsets.only(bottom: 5),
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
                                Navigator.of(context).pop();
                                _pickImageFromGallery();
                              }, child: Text('Galeri')),
                              TextButton(onPressed: (){
                                Navigator.of(context).pop();
                                _pickImageFromCamera();
                              }, child: Text('Kamera'))
                            ],
                          ),
                        ),
                      );
                    }
                  );
                },                                        
                icon: Icon(Icons.add_a_photo_outlined)
              )
            ),
          ),
        ),
      ),
    );
  }
}