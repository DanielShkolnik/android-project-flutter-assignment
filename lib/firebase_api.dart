import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseApi {

  static UploadTask? uploadFile(String destination, File file) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putFile(file);
    } on FirebaseException catch (e) {
      return null;
    }
  }

  static Future<String?> getUrl(String? uid) async {
    final ref;

    try{
      ref = FirebaseStorage.instance.ref("users/${uid}");
    }
    on UnimplementedError catch (_) {
      return null;
    }
    return ref.getDownloadURL();
    }

}