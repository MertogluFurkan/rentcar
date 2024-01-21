// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import 'colors.dart';
import 'widgets.dart';


class Discover extends StatefulWidget {
  const Discover({Key? key}) : super(key: key);

  @override
  State<Discover> createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  bool sortByPrice = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _textFieldController1 = TextEditingController();
  final TextEditingController _textFieldController2 = TextEditingController();
  final TextEditingController _textFieldController3 = TextEditingController();

  File? _image;

  final ImagePicker _picker = ImagePicker();

  void _deleteCar(String carId) async {
    try {
      await _firestore.collection('cars').doc(carId).delete();
      Navigator.pop(context);
    } catch (error) {
      print('Error deleting car: $error');
    }
  }

  void _sortCarsByPrice() {
    setState(() {
      sortByPrice = true;
    });
  }

  void _showCarDetailsBottomSheet(QueryDocumentSnapshot carSnapshot) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "DETAILS",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: "degular"),
              ),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(carSnapshot['imageUrl']),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    carSnapshot['carName'],
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: "kanitm"),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _editField(
                        context,
                        _textFieldController1,
                        'Car Name',
                        carSnapshot.id,
                        'carName',
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Price: ${carSnapshot['price']} Euro',
                    style: const TextStyle(fontSize: 16, fontFamily: "kanitm"),
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_money),
                    onPressed: () {
                      _editField(
                        context,
                        _textFieldController2,
                        'Price',
                        carSnapshot.id,
                        'price',
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Location: ${carSnapshot['location']}',
                    style: const TextStyle(fontSize: 16, fontFamily: "kanitm"),
                  ),
                  IconButton(
                    icon: const Icon(Icons.location_on),
                    onPressed: () {
                      _editField(
                        context,
                        _textFieldController3,
                        'Location',
                        carSnapshot.id,
                        'location',
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.lightBlue),
                    ),
                    onPressed: () {
                      _rentCar(carSnapshot);
                    },
                    child: Text(
                      'Rent',
                      style: TextStyle(color: color4, fontFamily: "degularb"),
                    ),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.lightBlue),
                    ),
                    onPressed: () {
                      _deleteCar(carSnapshot.id);
                    },
                    child: Text(
                      'Delete',
                      style: TextStyle(color: color4, fontFamily: "degularb"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.grey),
              SizedBox(height: 20),
              Text(
                "LOG IN...",
                style: TextStyle(fontFamily: "kanitm"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editField(
    BuildContext context,
    TextEditingController controller,
    String labelText,
    String carId,
    String fieldName,
  ) async {
    // Loading dialog'u göster

    try {
      await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Edit $labelText',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller,
                  keyboardType: (fieldName == 'price')
                      ? const TextInputType.numberWithOptions(decimal: true)
                      : TextInputType.text,
                  decoration: InputDecoration(
                    labelText: labelText,
                    prefixIcon: _getIconByFieldName(fieldName),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.lightBlue),
                  ),
                  onPressed: () async {
                    showLoadingDialog();

                    // Save butonuna basıldığında işlemi gerçekleştir
                    String newValue = controller.text;
                    await _updateCarField(carId, fieldName, newValue);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Save',
                    style: TextStyle(color: color4, fontFamily: "degularb"),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } finally {
      // Loading dialog'u kapat
      Navigator.of(context).pop();
    }
  }

  Icon _getIconByFieldName(String fieldName) {
    switch (fieldName) {
      case 'carName':
        return const Icon(Icons.directions_car);
      case 'price':
        return const Icon(Icons.attach_money);
      case 'location':
        return const Icon(Icons.location_on);
      default:
        return const Icon(Icons.edit);
    }
  }

  Future<String> uploadImage(File imageFile, String imageName) async {
    try {
      final ref =
          FirebaseStorage.instance.ref().child('car_images').child(imageName);

      await ref.putFile(imageFile);
      final imageUrl = await ref.getDownloadURL();

      return imageUrl;
    } catch (e) {
      print('Image upload error: $e');
      return ''; // Hata durumunda boş bir string dönebilirsiniz.
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  Future<void> _uploadCar() async {
    try {
      final imageUrl = await uploadImage(
          _image!, 'car_image_${DateTime.now().millisecondsSinceEpoch}');

      await _firestore.collection('cars').add({
        'carName': _textFieldController1.text,
        'price': double.tryParse(_textFieldController2.text) ?? 0.0,
        'location': _textFieldController3.text,
        'availability': false,
        'imageUrl': imageUrl,
      });

      _textFieldController1.clear();
      _textFieldController2.clear();
      _textFieldController3.clear();

      setState(() {
        _image = null;
      });

      // FlutterToast kullanarak toast mesajı göster
      Fluttertoast.showToast(
        msg: 'Car added successfully!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (error) {
      // Hata durumunda FlutterToast kullanarak toast mesajı göster
      Fluttertoast.showToast(
        msg: 'Error: $error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _updateCarField(
      String carId, String fieldName, String value) async {
    try {
      await _firestore.collection('cars').doc(carId).update({
        fieldName: value,
      });

      setState(() {
        // Güncelleme yapıldıktan sonra state'i güncelle
        _textFieldController1.text = '';
        _textFieldController2.text = '';
        _textFieldController3.text = '';
      });

      // FlutterToast kullanarak toast mesajı göster
      Fluttertoast.showToast(
        msg: 'Car updated successfully!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (error) {
      // Hata durumunda FlutterToast kullanarak toast mesajı göster
      Fluttertoast.showToast(
        msg: 'Error updating car: $error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _rentCar(QueryDocumentSnapshot carSnapshot) async {
    try {
      // Firestore'da ilgili belgeyi güncelle
      await _firestore.collection('cars').doc(carSnapshot.id).update({
        'availability': true,
      });

      // Rented Cars koleksiyonuna ekle
      await _firestore.collection('rentedcars').add({
        'carName': carSnapshot['carName'],
        'price': carSnapshot['price'],
        'location': carSnapshot['location'],
        'imageurl': carSnapshot['imageUrl'],
      });

      Fluttertoast.showToast(
        msg: 'Car rented successfully!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Error: $error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      home: Scaffold(
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ConvexButton.fab(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _textFieldController1,
                          decoration:
                              const InputDecoration(labelText: 'Car Name'),
                        ),
                        TextField(
                          controller: _textFieldController2,
                          decoration: const InputDecoration(labelText: 'Price'),
                        ),
                        TextField(
                          controller: _textFieldController3,
                          decoration:
                              const InputDecoration(labelText: 'Location'),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.lightBlue),
                          ),
                          onPressed: _pickImage,
                          child: const Text(
                            'Upload Image',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.lightBlue),
                          ),
                          onPressed: _uploadCar,
                          child: const Text(
                            'Add Car',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            icon: Icons.add,
            sigma: 25,
            iconSize: 32,
          ),
        ),
        backgroundColor: color4,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: IconButton(
                onPressed: _sortCarsByPrice,
                icon: const Icon(Icons.price_check),
              ),
            )
          ],
          elevation: 0,
          backgroundColor: color4,
          title: const Text('Discover Page'),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('cars').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            final cars = snapshot.data!.docs;

            if (sortByPrice) {
              cars.sort(
                  (a, b) => (b['price'] ?? 0.0).compareTo(a['price'] ?? 0.0));
            }

            return SingleChildScrollView(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cars.length,
                itemBuilder: (context, index) {
                  final carSnapshot = cars[index];

                  return CarCard(
                    carId: carSnapshot.id,
                    onTap: () {
                      _showCarDetailsBottomSheet(carSnapshot);
                    },
                    carName: carSnapshot['carName'] ?? '',
                    price: carSnapshot['price'] != null
                        ? (carSnapshot['price'] is num
                            ? (carSnapshot['price'] as num).toDouble()
                            : double.tryParse(carSnapshot['price']) ?? 0.0)
                        : 0.0,
                    location: carSnapshot['location'] ?? '',
                    availability: carSnapshot['availability'] ?? false,
                    imageUrl:
                        carSnapshot['imageUrl'] ?? 'assets/images/audi.jpg',
                  );
                },
                separatorBuilder: (context, index) => Column(
                  children: [
                    Divider(
                      color: color1,
                      thickness: 1,
                      indent: 30,
                      endIndent: 30,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
