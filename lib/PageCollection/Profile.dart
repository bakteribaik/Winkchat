import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:snapmatch/OtherProfile/OtherProfile.dart';
import 'package:snapmatch/PageCollection/EditProfile.dart';
import 'package:snapmatch/PageCollection/Comment.dart';
import 'package:snapmatch/Service/google_signin_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';


class UserProfile extends StatefulWidget {
  const UserProfile({ Key? key }) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> with AutomaticKeepAliveClientMixin<UserProfile> {

  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async{
    // monitor network fetch
    await Future.delayed(const Duration(seconds: 1));
    _refreshController.refreshCompleted();
    _getData = users.doc(_user!.email).get();
    _getPosting =  posting.where('POST-AUTHOR-ID', isEqualTo: _user!.uid).orderBy('TIMESTAMP', descending: true).get();
    setState(() {});
  }

  final _user = FirebaseAuth.instance.currentUser;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  CollectionReference posting = FirebaseFirestore.instance.collection('posting');

  late Future<DocumentSnapshot> _getData;
  late Future<QuerySnapshot> _getPosting;

  bool isLike = false;
  int like = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData = users.doc(_user!.email).get();
    _getPosting =  posting.where('POST-AUTHOR-ID', isEqualTo: _user!.uid).orderBy('TIMESTAMP', descending: true).get();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: const Text('', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 17),),
        actions: [
          GestureDetector(
            onTap: (){
              final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
              provider.logout();
              // Future.delayed(const Duration(seconds: 1),(){SystemNavigator.pop();});
                },
                child: Container(
                  padding: const EdgeInsets.only(top: 15, bottom: 15, right: 10),
                  child: Container(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.pink[300],
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child: const Text('logout',  style: TextStyle(fontSize: 11),),
                  ),
                ),
              )
            ],
          ),
      body: SafeArea(
        child: SmartRefresher(
          controller: _refreshController,
          onRefresh: _onRefresh,
          enablePullDown: true,
          enablePullUp: false,
          child: Container(
            child: Column(
              children: [
                    Container(
                      child: FutureBuilder<DocumentSnapshot>(
                        future: _getData,
                        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
                          if (snapshot.connectionState == ConnectionState.done) {
                            Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                            var follower = snapshot.data!.get('FOLLOWER') as List;
                            var following = snapshot.data!.get('FOLLOWING') as List;

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
                                        Text(data['USERNAME'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.lightBlue[200]),),                                                         

                                        const SizedBox(width: 3,),
                                        if(data['VERIFIED'] == true)
                                          const Image(image: AssetImage('assets/icons/verified_icon.png'), height: 15,)
                                        else
                                          const SizedBox(),                                                                                                                    
                                      ],
                                    ),
                                    Text('@${data['USER-ID']}', style: const TextStyle(fontSize: 14, color: Colors.grey),),
                                    const SizedBox(height: 5,),
                                    Text(data['BIO'], style: const TextStyle(fontSize: 14, color: Colors.grey),),
                                    const SizedBox(height: 5,),
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

                                    const SizedBox(height: 10,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: (){
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfile(
                                              nickname : data['USERNAME'],
                                              bio : data['BIO'],
                                              link : data['LINK'],
                                              tiktok : data['TIKTOK'],
                                              username : data['USER-ID']
                                            )));
                                          },
                                          child: Container(                                    
                                            height: 40,
                                            width: 120,
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              border: Border.all(width: 1, color: Colors.grey),
                                              borderRadius: BorderRadius.circular(5)
                                            ),
                                            child: const Center(child: Text('Edit Profile', style: TextStyle(color: Colors.grey),)),
                                          ),
                                        ),
                                        const SizedBox(width: 5,),
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
                                          const SizedBox()
                                      ],
                                    ),
                                    const SizedBox(height: 20,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Column(
                                          children: [
                                            Text(follower.length.toString(), style: const TextStyle(color: Colors.lightBlue)),                      
                                            Text('Followers', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink[200])),                                      
                                          ],
                                        ),
                                        const SizedBox(width: 100,),
                                        Column(
                                          children: [
                                            Text(following.length.toString(), style: const TextStyle(color: Colors.lightBlue)),                      
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


                   const SizedBox(height: 20,),//===============================


                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 15, top: 10, right: 20),
                        child: FutureBuilder<QuerySnapshot>(
                          future: _getPosting,
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
                                            Text(data['MESSAGE'],style: TextStyle(fontSize: 12, color: Colors.grey.shade700),),
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
          ),
        )
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: (){
      //     Navigator.push(context, MaterialPageRoute(builder: (context) => PostingPage()));
      //   },
      //   backgroundColor: Color(0xFF8D8DAA),
      //   mini: true,
      //   child: Container(
      //     margin: EdgeInsets.only(left: 5),
      //     child: Center(
      //       child: FaIcon(FontAwesomeIcons.filePen, size: 14,),
      //     ),
      //   ),
      // )
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}