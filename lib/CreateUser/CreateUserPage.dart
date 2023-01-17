import 'dart:async';

import 'package:age_calculator/age_calculator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapmatch/Router/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({ Key? key }) : super(key: key);

  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {

    final _user = FirebaseAuth.instance.currentUser;

    bool isSelectL = false;
    bool isSelectP = false;
    bool nameValid = false;
    bool BukaHalaman = false;

    TextEditingController username  = TextEditingController();
    TextEditingController tanggal  = TextEditingController();
    TextEditingController bulan  = TextEditingController();
    TextEditingController tahun  = TextEditingController();
    TextEditingController displayName  = TextEditingController();

    String queryNama = '';
    String token = '';
    int queryTanggal = 0;
    int queryBulan = 0;
    int queryTahun = 0;
    String gender = '';
    

    _addUser(int umur) async {
      if (nameValid == true) {
        CollectionReference users = FirebaseFirestore.instance.collection('users');
        users.
        doc(_user!.email).
        set({
          'JOINED' : DateTime.now().millisecondsSinceEpoch,
          'UID' : _user!.uid,
          'EMAIL' : _user!.email,
          'NAME' : _user!.displayName,
          'USERNAME' : displayName.text,
          'AGE' : umur,
          'GENDER' : gender,
          'DATE' : queryTanggal,
          'MONTH' : queryBulan,
          'YEAR' : queryTahun,
          'BIO' : 'Pendatang Baru',
          'LINK' : '',
          'TIKTOK' : '',
          'STATUS' : '',
          'LAST_ONLINE' : 0,
          'FOLLOWER' : [],
          'FOLLOWING' : [],
          'VERIFIED': false,
          'ADMIN' : false,
          'MODERATOR' : false,
          'BANNED' : false,
          'USER-TOKEN' : token,
          'USER-ID' : username.text
        })
        .then((value) => print('user added'))
        .catchError((error) => print('Cant add user: $error'));

        Navigator.of(context).pop();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoadingPage()));
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFFF56D91),
            content: Text('username sudah digunakan!', textAlign: TextAlign.center,),
          )
        );
        username.clear();
      }
    }

    _cekUsername(){
      CollectionReference users = FirebaseFirestore.instance.collection('users');
      users.where('USERNAME', isEqualTo: queryNama).get().then((QuerySnapshot query){
        if (query.docs.isEmpty) {
          setState(() {
            nameValid = true;
          });
        }else{
          setState(() {
            nameValid = false;
          });
        }
      });
    }

    _getUserToken() async {
      await FirebaseMessaging.instance.getToken().then((value){
        setState(() {
          token = value.toString();
          print('TOKEN DIDAPATKAN: $token');
        });
      });
    }    

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUserToken();
    BukaHalaman = true;
    Timer.periodic(const Duration(milliseconds: 500), (timer){
       if(BukaHalaman == true){         
         _cekUsername();
         print(BukaHalaman);
       }else{
         timer.cancel();
       }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    BukaHalaman = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Silahkan buat profilmu', style: TextStyle(color: Colors.lightBlue[300],  fontSize: 14),)
                ],
              ),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.only(left: 60, right: 60),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                nameValid ?
                Text('*username hanya terdiri dari huruf kecil dan angka', style: TextStyle(fontSize: 11, color: Colors.pink[200]), textAlign: TextAlign.center,)
                :
                Text('username sudah digunakan!', style: TextStyle(color: Colors.red[300], fontSize: 11),),
                const SizedBox(height: 20,),

                Container(
                  padding: const EdgeInsets.only(left: 15, top: 10, bottom: 5, right: 10),
                  height: 70,
                  width: 250,
                  decoration: BoxDecoration(
                    color: Colors.lightBlue[50],
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: TextFormField(
                    style: TextStyle(color: Colors.black45),
                    autocorrect: false,
                    controller: displayName,
                    maxLength: 20,
                    decoration: InputDecoration(                       
                      hintText: 'Nama Kamu',
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                      counterText: '',
                      border: InputBorder.none,                                      
                    ),
                  ),
                ),

                SizedBox(height: 10,),
                
                Container(
                  padding: const EdgeInsets.only(left: 15, top: 10, bottom: 5, right: 10),
                  height: 70,
                  width: 250,
                  decoration: BoxDecoration(
                    color: Colors.lightBlue[50],
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: TextFormField(
                    style: TextStyle(color: nameValid ? Colors.black45 : Colors.red[300]),
                    autocorrect: false,        
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[a-z0-9]'))
                    ],
                    controller: username,
                    onChanged: (value){
                        _cekUsername();
                        setState(() {
                          queryNama = value;
                        });
                      },
                    maxLength: 20,
                    decoration: InputDecoration(  
                      suffixIcon: nameValid ? const Icon(Icons.check, size: 20,) : const Icon(Icons.close, size: 20, color: Colors.red,),
                      hintText: 'username',
                      hintStyle: const TextStyle(color: Colors.grey),
                      counterText: '',
                      border: InputBorder.none,                                      
                    ),
                  ),
                ),
      
                const SizedBox(height: 10,),
                Container(
                  padding: EdgeInsets.only(left: 10),
                  width: MediaQuery.of(context).size.width,
                  child: Text('Jenis Kelamin', style: TextStyle(color: Colors.lightBlue[300], fontWeight: FontWeight.bold))
                ),
                const SizedBox(height: 10,),

                Container( //gender Container
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: (){
                          if (isSelectL) {
                            setState(() {
                              isSelectL = false;
                            });
                          } else {
                            setState(() {
                              isSelectL = true;
                              isSelectP = false;
                              gender = 'L';
                            });
                          }
                        },
                        child: Container(
                          height: 50,
                          width: 120,
                          decoration: BoxDecoration(
                            color: isSelectL ? Colors.lightBlue[300] : Color.fromARGB(61, 79, 194, 247),
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Center(child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.male, size: 20, color: isSelectL ? Colors.white : Colors.grey[400],),
                              Text('Laki Laki', style: TextStyle(color: isSelectL ? Colors.white : Colors.grey[400],),)
                            ],
                          )),
                        ),
                      ),
                      const SizedBox(width:10),
                      GestureDetector(
                        onTap: (){
                          if (isSelectP) {
                            setState(() {
                              isSelectP = false;
                            });
                          } else {
                            setState(() {
                              isSelectP = true;
                              isSelectL = false;
                              gender = 'P';
                            });
                          }
                        },
                        child: Container(
                          height: 50,
                          width: 120,
                          decoration: BoxDecoration(
                            color: isSelectP ? Colors.pink[200] : Color.fromARGB(61, 244, 143, 177),
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Center(child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.female, size: 20, color: isSelectP ? Colors.white : Colors.grey[400],),
                              Text('Wanita', style: TextStyle(color: isSelectP ? Colors.white : Colors.grey[400],),)
                            ],
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10,),
                Container(
                  padding: EdgeInsets.only(left: 10),
                  width: MediaQuery.of(context).size.width,
                  child: Text('Tanggal Lahir', style: TextStyle(color: Colors.lightBlue[300], fontWeight: FontWeight.bold))
                ),
                const SizedBox(height: 10,),

                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 5),
                        height: 50,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.lightBlue[50],
                          borderRadius: BorderRadius.circular(15)
                        ),
                        child: TextField(
                          style: TextStyle(color: Colors.grey),
                          controller: tanggal,
                          onChanged: (value){
                            setState(() {
                              if (value.isNotEmpty) {
                                queryTanggal = int.parse(value);
                              }                            
                            });
                          },
                          keyboardType: TextInputType.number,
                          maxLength: 2,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            hintText: 'Tanggal',
                            hintStyle: TextStyle(color: Colors.white),
                            counterText: '',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5,),
                      Container(
                        padding: const EdgeInsets.only(top: 5),
                        height: 50,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.lightBlue[50],
                          borderRadius: BorderRadius.circular(15)
                        ),
                        child: TextField(
                          style: TextStyle(color: Colors.grey),
                          controller: bulan,
                          onChanged: (value){
                            setState(() {
                              if (value.isNotEmpty) {
                                queryBulan = int.parse(value);
                              }                            
                            });
                          },
                          keyboardType: TextInputType.number,
                          maxLength: 2,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            hintText: 'Bulan',
                            hintStyle: TextStyle(color: Colors.white),
                            counterText: '',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5,),
                      Container(
                        padding: const EdgeInsets.only(top: 5),
                        height: 50,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.lightBlue[50],
                          borderRadius: BorderRadius.circular(15)
                        ),
                        child: TextField(
                          style: TextStyle(color: Colors.grey),
                          controller: tahun,
                          onChanged: (value){
                            setState(() {
                              if(value.isNotEmpty){
                                queryTahun = int.parse(value);
                              }
                            });
                          },
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            hintText: 'Tahun',
                            hintStyle: TextStyle(color: Colors.white),
                            counterText: '',
                            border: InputBorder.none,
                          ),
                        ),
                      ),                   
                    ],
                  ),
                ),

                const SizedBox(height: 80,),

                GestureDetector(
                  onTap: (){
                    DateTime birtday = DateTime(queryTahun, queryBulan, queryTanggal);
                    DateDuration duration = DateDuration();
                    duration = AgeCalculator.age(birtday);                      
                    if (queryNama.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Color(0xFF235270),
                          content: Text('username belum di isi!', textAlign: TextAlign.center,),
                        )
                      );
                    }else if (queryTanggal.isNaN) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Color(0xFF235270),
                          content: Text('Tanggal belum di isi!', textAlign: TextAlign.center,),
                        )
                      );
                    }else if (queryBulan.isNaN) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Color(0xFF235270),
                          content: Text('Bulan belum di isi!', textAlign: TextAlign.center,),
                        )
                      );
                    }else if (queryTahun.isNaN) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Color(0xFF235270),
                          content: Text('Tahun belum di isi!', textAlign: TextAlign.center,),
                        )
                      );
                    }else if (gender.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Color(0xFF235270),
                          content: Text('Silahkan pilih gender L/P!', textAlign: TextAlign.center,),
                        )
                      );
                    }else if(queryBulan > 12){
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Color(0xFF235270),
                          content: Text('Mohon isi bulan dengan benar!', textAlign: TextAlign.center,),
                        )
                      );
                      bulan.clear();
                    }else if (queryTanggal > 31) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Color(0xFF235270),
                          content: Text('Mohon isi Tanggal dengan benar!', textAlign: TextAlign.center,),
                        )
                      );
                      tanggal.clear();
                    }else if (queryTahun > DateTime.now().year - 13) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Color(0xFF235270),
                          content: Text('Umur anda tidak mencukupi!', textAlign: TextAlign.center,),
                        )
                      );
                      tahun.clear();
                    }
                    else if (queryTahun < 1987) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Color(0xFF235270),
                          content: Text('Anda sudah tidak muda lagi loh!', textAlign: TextAlign.center,),
                        )
                      );
                      tahun.clear();
                    }
                    else if (queryNama.toLowerCase().contains('admin')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Color(0xFF235270),
                          content: Text('Anda tidak dapat menggunakan kata tersebut!!', textAlign: TextAlign.center,),
                        )
                      );
                      username.clear();
                    }
                    else if (queryNama.toLowerCase().contains('snapmatch')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Color(0xFF235270),
                          content: Text('Anda tidak dapat menggunakan kata tersebut!!', textAlign: TextAlign.center,),
                        )
                      );
                      username.clear();
                    }                  
                    else {                   
                      showDialog(
                        context: context, 
                        builder: (BuildContext context){                        
                          return AlertDialog(
                            actionsAlignment: MainAxisAlignment.center,
                            title: Text('Usia anda ${duration.years} tahun', textAlign: TextAlign.center,style: TextStyle(fontSize: 14, color: Colors.pink[200]),),
                            content: Text('${displayName.text}, kami berharap anda dapat menjaga komunitas dengan baik, tentunya dengan berperilaku dengan baik juga', style: TextStyle(fontSize: 13, color: Colors.lightBlue[300]), textAlign: TextAlign.center,),
                            actions: [     
                              GestureDetector(
                                  onTap: (){
                                    _addUser(duration.years);                                                           
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: 250,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.lightBlue[300],
                                      borderRadius: BorderRadius.circular(10)
                                    ),
                                    child: const Center(child: Text('setuju dan lanjutkan', style: TextStyle(color: Colors.white),)),
                                  ),
                              ),                           
                            ],
                          );
                        }
                      );
                    }
                  },               
                  child: Container(
                    height: 50,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.lightBlue[300],
                      borderRadius: BorderRadius.circular(15)
                    ),
                    child: const Center(child: Text('Daftar', style: TextStyle(color: Colors.white),)),
                    ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}