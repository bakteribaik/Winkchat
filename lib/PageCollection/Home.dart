import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:snapmatch/OtherProfile/OtherProfile.dart';

class UserHome extends StatefulWidget {
  const UserHome({ Key? key }) : super(key: key);

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome>{

  late Future<QuerySnapshot> _usersStream;

  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async{
    // monitor network fetch
    await Future.delayed(const Duration(seconds: 1));
    _refreshController.refreshCompleted();
    _usersStream = FirebaseFirestore.instance.collection('users').get();
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _usersStream = FirebaseFirestore.instance.collection('users').get();
  }
   
  @override
  Widget build(BuildContext context) {
    return Scaffold(      
      body: SafeArea(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Container(       
                  width: MediaQuery.of(context).size.width,           
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.lightBlue[300],
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Center(child: Text('Temukan bestie mu, sekarang', style: const TextStyle(color: Colors.white, fontSize: 14), textAlign: TextAlign.center)),
                ),
                
                const SizedBox(height: 20,),
                Expanded(
                    child: SmartRefresher(
                      controller: _refreshController,
                      onRefresh: _onRefresh,
                      enablePullDown: true,
                      enablePullUp: false,
                      child: Container(
                        child: FutureBuilder<QuerySnapshot>(
                          future: _usersStream,
                          builder: (context, snapshot){
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator(color: Colors.pink[200],),);
                            }
                            return ListView(
                              physics: BouncingScrollPhysics(),
                              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                                return GestureDetector(
                                  onTap: (){
                                    print('DARI HOME: ${data['USER-TOKEN']}');
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => OtherProfile(
                                      name_user : data['USERNAME'],
                                      id_user : data['UID'],
                                      email_user : data['EMAIL'],
                                      UserToken: data['USER-TOKEN'],
                                      UserGender: data['GENDER'],
                                    )));
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    color: Colors.transparent,
                                    padding: const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        children: [
                                          CircleAvatar(backgroundColor: Colors.lightBlue[50]),
                                          const SizedBox(width: 8,),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(data['USERNAME'], style: TextStyle(fontWeight: FontWeight.bold, color: Colors.lightBlue[300]),),
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
                                                  // if (data['GENDER'] == 'P') 
                                                  //   Container(
                                                  //     margin: const EdgeInsets.only(left: 3), 
                                                  //   height: 10,
                                                  //   width: 15,
                                                  //   decoration: BoxDecoration(
                                                  //     color: Colors.pink[100],
                                                  //     borderRadius: BorderRadius.circular(10)
                                                  //   ),
                                                  //   child: const Center(
                                                  //     child: Icon(Icons.female, size: 10, color: Colors.pink,),
                                                  //   ),
                                                  // )
                                                  // else
                                                  // Container(
                                                  //   margin: const EdgeInsets.only(left: 3), 
                                                  //   height: 10,
                                                  //   width: 15,
                                                  //   decoration: BoxDecoration(
                                                  //     color: Colors.blue[100],
                                                  //     borderRadius: BorderRadius.circular(10)
                                                  //   ),
                                                  //   child: const Center(
                                                  //     child: Icon(Icons.male, size: 10, color: Colors.blue,),
                                                  //   ),
                                                  // ),
                                                  // if(data['STATUS'] == 'ONLINE')
                                                  // Container(
                                                  //   margin: const EdgeInsets.only(left: 3),                                      
                                                  //   padding: const EdgeInsets.only(left: 5, right: 5, top: 1, bottom: 1),
                                                  //   decoration: BoxDecoration(
                                                  //     border: Border.all(width: 0.5, color: Colors.green),
                                                  //     borderRadius: BorderRadius.circulawhr(30)
                                                  //   ),
                                                  //   child: const Text('online', style: TextStyle(fontSize: 8, color: Colors.green),),
                                                  // )
                                                  // else 
                                                  // SizedBox()
                                                ],
                                              ),
                                              
                                              Text(data['BIO'],  style: const TextStyle(fontSize: 13, color: Colors.grey),),
                                            ],
                                          ),                      
                                        ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ),
                  ),    
              ],
            )
          ),
        ),
      ),
    );
  }
}