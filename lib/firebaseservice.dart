import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebasestorage_service.dart';
import 'widgets.dart';


class FirebaseService {
    bool sortByPrice = false;

  final CollectionReference carCollection =
      FirebaseFirestore.instance.collection('cars');

  final FirebaseStorageService storageService = FirebaseStorageService();

  Future<void> addCar(String carName, double price, String location,
      bool availability, File imageFile) async {
    String imageUrl = await storageService.uploadImage(imageFile, carName);

    await carCollection.add({
      'carName': carName,
      'price': price,
      'location': location,
      'availability': availability,
      'imageUrl': imageUrl,
    });
  }

  Future<List<CarCard>> getCarsSortedByPrice() async {
    QuerySnapshot<Object?> querySnapshot =
        await carCollection.orderBy('price', descending: true).get();

    return _mapQuerySnapshotToCarCards(querySnapshot);
  }

  List<CarCard> _mapQuerySnapshotToCarCards(QuerySnapshot<Object?> querySnapshot) {
    return querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return CarCard(
        carId: "",
        carName: data['carName'],
        price: data['price'],
        location: data['location'],
        availability: data['availability'],
        imageUrl: data['imageUrl'],
        onTap: () {
          // Buraya tıklama işlemleri ekleyebilirsiniz
        },
      );
    }).toList();
  }
}
