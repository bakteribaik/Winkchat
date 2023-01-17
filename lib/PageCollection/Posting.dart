import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../Service/storage_services.dart';

class PostingPage extends StatefulWidget {
  const PostingPage({ Key? key }) : super(key: key);

  @override
  State<PostingPage> createState() => _PostingPageState();
}

class _PostingPageState extends State<PostingPage> {

  final _user = FirebaseAuth.instance.currentUser;
  CollectionReference posting = FirebaseFirestore.instance.collection('posting');
  TextEditingController postingController = TextEditingController();

  String query = '';
  String nama = '';
  String gender = '';
  String namaFile = '';
  String pict_url = '';
  String token = '';
  String user_id = '';
  int umur = 0;
  bool verified = false;
  bool admin = false;
  bool moderator = false;
  bool uploading = false;

  final Storage storage = Storage();

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
  

  _addPost(){
    posting
      .add({
        'PICT_URL' : pict_url,
        'POST-ID' : '',
        'POST-AUTHOR-ID' : _user!.uid,
        'POST-AUTHOR-EMAIL' : _user!.email,
        'USERNAME' : nama,
        'AGE' : umur,
        'GENDER' : gender,
        'MESSAGE' : query,
        'TIMESTAMP' : DateTime.now().millisecondsSinceEpoch,
        'LIKE' : 0,
        'VERIFIED' : verified,
        'ADMIN' : admin,
        'MODERATOR' : moderator,
        'PINNED' : false,
        'USER-TOKEN' : token,
        'Z_LIKERS' : [],
        'USER-ID' : user_id
      })
      .then((value){
        posting
          .doc(value.id)
          .update({
            'POST-ID' : value.id
          });
        
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0.0,
            backgroundColor: Colors.pink[200],
            content: const Text('Posting Berhasil: Refresh untuk update', textAlign: TextAlign.center,),
          )
        );
        setState(() {});
      });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseFirestore.instance
      .collection('users')
      .doc(_user!.email)
      .get()
      .then((DocumentSnapshot data) {
        setState(() {
          nama = data["USERNAME"];
          gender = data['GENDER'];
          umur = data['AGE'];
          verified = data['VERIFIED'];
          admin = data['ADMIN'];
          moderator = data['MODERATOR'];
          token = data['USER-TOKEN'];
          user_id = data['USER-ID'];
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        actions: [
          GestureDetector(
            onTap: (){
              if (image != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sedang mengupload file...'))
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

                  _addPost();
                });
              }else{
                 _addPost();
              }
            },        
            child: Container(
              padding: const EdgeInsets.only(top: 15, bottom: 15, right: 10),
              child: Container(
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.lightBlue,
                  borderRadius: BorderRadius.circular(10)
                ),
                child: const Center(
                  child: Text('post', style: TextStyle(),),
                ),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(10),   
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors. white
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15)
                    ),
                    child: TextField(
                      controller: postingController,
                      onChanged: (value){
                        setState(() {
                          query = value;
                        });
                      },
                      autocorrect: false,
                      autofocus: true,
                      maxLength: 500,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'penting untuk diingat!! jika postingan kamu\nberbau SARA atau pornografi. kami akan\nmembanned akun anda secara langsung\ntanpa konfirmasi',
                        hintStyle: TextStyle(color: Colors.grey[300], fontSize: 15),
                        border: InputBorder.none,
                        counterText: ''
                      ),
                    ),
                  ),

                  Divider(),
                  SizedBox(height: 10,),

                  GestureDetector(
                    onTap: (){
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
                                  }, child: Text('Ambil dari Gallery')),
                                  TextButton(onPressed: (){
                                    Navigator.of(context).pop();
                                    _pickImageFromCamera();
                                  }, child: Text('Ambil dari Kamera'))
                                ],
                              ),
                            ),
                          );
                        }
                      );
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.lightBlue[100],
                              borderRadius: BorderRadius.circular(10)
                            ),
                            child: image != null ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(image!, fit: BoxFit.cover,)) : Center(child: FaIcon(FontAwesomeIcons.plus, size: 30, color: Colors.lightBlue[50],),),
                          ),
                        ),

                        image != null ?
                          Positioned(
                            left: 80,
                            bottom: 80,
                            child: GestureDetector(
                              onTap: (){
                                setState(() {
                                  image = null;
                                });
                              },
                              child: Container(
                                color: Colors.transparent,
                                child: CircleAvatar(
                                  radius: 13,
                                  backgroundColor: Colors.lightBlue[100],
                                  child: Icon(Icons.close, size: 15, color: Colors.lightBlue,),
                                ),
                              ),
                            ),
                          ) : SizedBox()
                      ],
                    ),
                  ),              
                ],
              ),
            )          
        )
      ),
    );
  }
}