import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;

class Storage{
  final firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;

  Future<void> uploadFile(String FilePath, String FileName) async {
    File file = File(FilePath);

    try{
      await storage.ref('post_pict/$FileName').putFile(file);
    }on firebase_core.FirebaseException catch (e){
      print(e.toString());
    }
  }

  downloadURL(String Filename) async {
    await storage.ref('post_pict/$Filename').getDownloadURL();
  }
}