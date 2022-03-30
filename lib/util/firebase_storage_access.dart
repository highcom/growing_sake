import 'dart:async';
import 'dart:io' as io;

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseStorageAccess {
  static Future<firebase_storage.UploadTask?> uploadFile(String dirName, String imageName, XFile? file) async {
    if (file == null) {
      return null;
    }

    firebase_storage.UploadTask uploadTask;

    // Create a Reference to the file
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child(dirName)
        .child(imageName + '.JPG');

    final metadata = firebase_storage.SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': file.path});

    if (kIsWeb) {
      uploadTask = ref.putData(await file.readAsBytes(), metadata);
    } else {
      uploadTask = ref.putFile(io.File(file.path), metadata);
    }

    return Future.value(uploadTask);
  }

  static Future<String?> downloadFile(String path) async {
    final ref = firebase_storage.FirebaseStorage.instance.ref().child(path);
    try {
      return await ref.getDownloadURL();
    } on firebase_storage.FirebaseException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return null;
  }
}