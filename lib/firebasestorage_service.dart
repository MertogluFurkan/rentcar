import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage =
      FirebaseStorage.instanceFor(bucket: 'gs://rentcar-ff46e.appspot.com');

  Future<String> uploadImage(File imageFile, String imageName) async {
    try {
      UploadTask uploadTask = _storage.ref('images/$imageName').putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }
}
