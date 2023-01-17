
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:snapmatch/PageCollection/Chat.dart';
import 'package:snapmatch/PageCollection/Home.dart';
import 'package:snapmatch/PageCollection/Profile.dart';
import 'package:snapmatch/PageCollection/Timeline.dart';
import 'package:snapmatch/main.dart';

import '../PageCollection/Posting.dart';

class HomePage extends StatefulWidget {
  const HomePage({ Key? key }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {

  bool showBadge = false;
  bool limit = false;

  final _user = FirebaseAuth.instance.currentUser;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (_user != null) {
      users
        .doc(_user!.email)
        .update({
          'STATUS' : 'ONLINE'
        })
        .then((value) => print('USER FIRST OPEN AND ONLINE'));
    }

    // FirebaseFirestore.instance
    //   .collection('system')
    //   .doc('system')
    //   .get()
    //   .then((value){
    //     if(value.exists){
    //       var data = value.data() as Map<String, dynamic>;
    //       if(data['isLimit'] == true){
    //         setState(() {
    //           limit = true;
    //         });
    //       }else{
    //         setState(() {
    //           limit = false;
    //         });
    //       }
    //     }
    //   });

    WidgetsBinding.instance.addObserver(this);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              playSound : true,         
              icon: '@mipmap/ic_launcher',
            )
          )
        );
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;
      if (notification != null && android != null) {
        setState(() {
          showBadge = true;  
        });
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        showDialog(context: context, builder: (context){
          return AlertDialog(
            title: Text(notification.title.toString(), textAlign: TextAlign.center,),
            content: SingleChildScrollView(            
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(notification.body.toString())
                ],
              ),
            ),
          );
        });
      }
    });
  } 

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      users
        .doc(_user!.email)
        .update({
          'STATUS' : 'ONLINE'
        })
        .then((value) => print('USER HAS ONLINE'));
    } else {
      users
        .doc(_user!.email)
        .update({
          //'LAST_ONLINE' : DateTime.now().millisecondsSinceEpoch,
          'STATUS' : 'OFFLINE'
        })
        .then((value) => print('USER HAS OFFLINE'));
    }
  }

  final pageController = PageController(
    initialPage: 1
  );

  bool page1 = false;
  bool page2 = true;
  bool page3 = false;
  bool page4 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(   
      body: SafeArea(
        child: Stack(
          children: [
            
            Container(
              child: Column(
                children: [
                  Expanded(
                  child: PageView(    
                    physics: const NeverScrollableScrollPhysics(),          
                    pageSnapping: true,
                    controller: pageController,
                    children: const [
                      UserHome(),
                      UserTimeline(),
                      UserChat(),
                      UserProfile()
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.top),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    height: 55,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: (){
                              pageController.jumpToPage(0);
                              setState(() {
                                page1 = true;
                                page2 = false;
                                page3 = false;
                                page4 = false;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(top: 5),
                              color: Colors.transparent,
                              width: MediaQuery.of(context).size.width / 5.2,
                              child: Column(
                                children: [
                                  Icon(Icons.home_outlined, color: page1 ? Colors.lightBlue[200] : Colors.grey[300],),
                                  Text('Home', style: TextStyle(fontSize: 10, color: page1 ? Colors.lightBlue[200] : Colors.grey[400], ))
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: (){
                              pageController.jumpToPage(1);
                              setState(() {
                                page1 = false;
                                page2 = true;
                                page3 = false;
                                page4 = false;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(top: 5),
                              color: Colors.transparent,
                              width: MediaQuery.of(context).size.width / 5.2,
                              child: Column(
                                children: [
                                  Icon(Icons.timeline, color: page2 ? Colors.lightBlue[200] : Colors.grey[300],),
                                  Text('Beranda', style: TextStyle(fontSize: 10, color: page2 ? Colors.lightBlue[200] : Colors.grey[400], ))
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const PostingPage()));
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.lightBlue[200],
                              child: FaIcon(FontAwesomeIcons.plus),
                            )
                          ),
                          GestureDetector(
                            onTap: (){                 
                              pageController.jumpToPage(2);
                              setState(() {
                                showBadge = false;
                                page1 = false;
                                page2 = false;
                                page3 = true;
                                page4 = false;
                              });
                            },
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  color: Colors.transparent,
                                  width: MediaQuery.of(context).size.width / 5.2,
                                  child: Column(
                                    children: [
                                      FaIcon(FontAwesomeIcons.comment, color: page3 ? Colors.lightBlue[200] : Colors.grey[300], size: 21,),
                                      Text('Obrolan', style: TextStyle(fontSize: 10, color: page3 ? Colors.lightBlue[200] : Colors.grey[400], ))
                                    ],
                                  ),
                                ),
                                showBadge ?
                                Positioned(
                                  top: 3,
                                  right: 25,
                                  child: CircleAvatar(
                                    maxRadius: 5,
                                    backgroundColor: Colors.pink[300],
                                  )
                                ) : SizedBox()
                              ],
                            )
                          ),
                          GestureDetector(
                            onTap: (){
                              pageController.jumpToPage(3);
                              setState(() {
                                page1 = false;
                                page2 = false;
                                page3 = false;
                                page4 = true;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(top: 5),
                              color: Colors.transparent,
                              width: MediaQuery.of(context).size.width / 5.2,
                              child: Column(
                                children:[
                                  Icon(Icons.people_alt_outlined, color: page4 ? Colors.lightBlue[200] : Colors.grey[300],),
                                  Text('Saya', style: TextStyle(fontSize: 10, color: page4 ? Colors.lightBlue[200] : Colors.grey[400], ))
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ],
              ),
            ),

            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('system').doc('system').snapshots(),
              builder: (context, snapshot){
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox();
                }
                var data = snapshot.data!.data() as Map<String, dynamic>;        
               
                    return data['isLimit'] == true ? Center(
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        color: Color.fromARGB(167, 87, 87, 87),
                        padding: EdgeInsets.only(left: 50, right: 50, top: 200, bottom: 150),
                        child: Container(
                          height: 150,
                          width: 150,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15)
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.timeline, color: Colors.red, size: 30,),
                                Text('Batas tercapai!!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),),
                                SizedBox(height: 10,),
                                Text('Mohon maaf apabila kenyamanan anda terganggu\n\n saat ini snapmatch sedang mengalami limit pada database, sehingga tidak memungkinkannya untuk menulis apapun pada aplikasi\n\nbuka aplikasi kembali pada esok harinya, terimakasih 😊\n\n\nkenapa bisa limit? karna servernya masih pakai yang gratisan 😢', textAlign: TextAlign.center,style: TextStyle(color: Colors.grey, fontSize: 13))
                              ],
                            )
                          ),
                        ),
                      ),
                    ) : SizedBox();            
              },
            ),          
          ],
        )
      ),      
      // bottomNavigationBar: limit ? SizedBox() : Container(
      //   padding: const EdgeInsets.all(5),
      //   height: 55,
      //   decoration: const BoxDecoration(
      //     color: Colors.white,
      //   ),
      //   child: Center(
      //     child: Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceAround,
      //       children: [
      //         GestureDetector(
      //           onTap: (){
      //             pageController.jumpToPage(0);
      //             setState(() {
      //               page1 = true;
      //               page2 = false;
      //               page3 = false;
      //               page4 = false;
      //             });
      //           },
      //           child: Container(
      //             margin: const EdgeInsets.only(top: 5),
      //             color: Colors.transparent,
      //             width: MediaQuery.of(context).size.width / 5.2,
      //             child: Column(
      //               children: [
      //                 Icon(Icons.home_outlined, color: page1 ? Colors.lightBlue[200] : Colors.grey[300],),
      //                 Text('Home', style: TextStyle(fontSize: 10, color: page1 ? Colors.lightBlue[200] : Colors.grey[400], ))
      //               ],
      //             ),
      //           ),
      //         ),
      //         GestureDetector(
      //           onTap: (){
      //             pageController.jumpToPage(1);
      //             setState(() {
      //               page1 = false;
      //               page2 = true;
      //               page3 = false;
      //               page4 = false;
      //             });
      //           },
      //           child: Container(
      //             margin: const EdgeInsets.only(top: 5),
      //             color: Colors.transparent,
      //             width: MediaQuery.of(context).size.width / 5.2,
      //             child: Column(
      //               children: [
      //                 Icon(Icons.timeline, color: page2 ? Colors.lightBlue[200] : Colors.grey[300],),
      //                 Text('Beranda', style: TextStyle(fontSize: 10, color: page2 ? Colors.lightBlue[200] : Colors.grey[400], ))
      //               ],
      //             ),
      //           ),
      //         ),
      //         GestureDetector(
      //           onTap: (){
      //             Navigator.push(context, MaterialPageRoute(builder: (context) => const PostingPage()));
      //           },
      //           child: Container(
      //             padding: const EdgeInsets.only(top: 1, bottom: 1, left: 10,right: 10),
      //             margin: const EdgeInsets.only(top: 5),
      //             color: Colors.transparent,
      //             width: MediaQuery.of(context).size.width / 5.2,
      //             child: Container(                    
      //               padding: const EdgeInsets.only(left: 5, bottom: 5,right: 2, top: 1),     
      //               decoration: BoxDecoration(
      //                 //border: Border.all(width: 1,color: Colors.lightBlue[200]),
      //                 color: const Colors.lightBlue[200],
      //                 borderRadius: BorderRadius.circular(15)
      //               ),
      //               child: const Center(
      //                 child: Text('+', style: TextStyle(fontSize: 30, color: Colors.white),),
      //               ),
      //               // child: Column(
      //               //   children: [
      //               //     Icon(Icons.add_card, color: Colors.lightBlue[200], size: 20,),
      //               //     Text('Posting', style: TextStyle(fontSize: 10, color: Colors.lightBlue[200], ))
      //               //   ],
      //               // ),
      //             ),
      //           ),
      //         ),
      //         GestureDetector(
      //           onTap: (){                 
      //             pageController.jumpToPage(2);
      //             setState(() {
      //               showBadge = false;
      //               page1 = false;
      //               page2 = false;
      //               page3 = true;
      //               page4 = false;
      //             });
      //           },
      //           child: Stack(
      //             clipBehavior: Clip.none,
      //             children: [
      //               Container(
      //                 margin: const EdgeInsets.only(top: 8),
      //                 color: Colors.transparent,
      //                 width: MediaQuery.of(context).size.width / 5.2,
      //                 child: Column(
      //                   children: [
      //                     FaIcon(FontAwesomeIcons.comment, color: page3 ? Colors.lightBlue[200] : Colors.grey[300], size: 21,),
      //                     Text('Obrolan', style: TextStyle(fontSize: 10, color: page3 ? Colors.lightBlue[200] : Colors.grey[400], ))
      //                   ],
      //                 ),
      //               ),
      //               showBadge ?
      //               Positioned(
      //                 top: 3,
      //                 right: 25,
      //                 child: CircleAvatar(
      //                   maxRadius: 5,
      //                   backgroundColor: Colors.pink[300],
      //                 )
      //               ) : SizedBox()
      //             ],
      //           )
      //         ),
      //         GestureDetector(
      //           onTap: (){
      //             pageController.jumpToPage(3);
      //             setState(() {
      //               page1 = false;
      //               page2 = false;
      //               page3 = false;
      //               page4 = true;
      //             });
      //           },
      //           child: Container(
      //             margin: const EdgeInsets.only(top: 5),
      //             color: Colors.transparent,
      //             width: MediaQuery.of(context).size.width / 5.2,
      //             child: Column(
      //               children:[
      //                 Icon(Icons.people_alt_outlined, color: page4 ? Colors.lightBlue[200] : Colors.grey[300],),
      //                 Text('Saya', style: TextStyle(fontSize: 10, color: page4 ? Colors.lightBlue[200] : Colors.grey[400], ))
      //               ],
      //             ),
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}