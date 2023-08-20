// // ignore_for_file: unused_import

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/services.dart';
// import 'package:uuid/uuid.dart';

// class StorageMethods {
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   //adding image to firebase storage

//   Future<String> uploadImageToStorage(
//       String childName, Uint8List file, bool isPost) async {
//     Reference ref =
//         _storage.ref().child(childName).child(_auth.currentUser!.uid);

//     if (isPost) {
//       String id = const Uuid().v1();
//       ref = ref.child(id);
//     }

//     UploadTask uploadTask = ref.putData(file);

//     TaskSnapshot snap = await uploadTask;
//     String downloadUrl = await snap.ref.getDownloadURL();
//     return downloadUrl;
//   }
// }

// Chatgpt code

// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:typed_data';

class StorageMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Adding image to Firebase Storage with resizing

  Future<String> uploadImageToStorage(
      String childName, Uint8List file, bool isPost) async {
    Reference ref =
        _storage.ref().child(childName).child(_auth.currentUser!.uid);

    if (isPost) {
      String id = const Uuid().v1();
      ref = ref.child(id);
    }

    // Resize the image using flutter_image_compress
    List<int> compressedImageData = await FlutterImageCompress.compressWithList(
      file,
      quality: 50,
      minHeight: 720,
      minWidth: 1280,
    );

    // Convert the List<int> to Uint8List

    Uint8List compressedImageUint8List =
        Uint8List.fromList(compressedImageData);

    UploadTask uploadTask = ref.putData(compressedImageUint8List);

    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }
}
