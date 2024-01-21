import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'colors.dart';

class CarCard extends StatelessWidget {
  final String carName;
  final String carId;

  final double price;
  final String location;
  final bool availability;
  final String imageUrl;
  final VoidCallback onTap;

  const CarCard({
    required this.carId,
    required this.carName,
    required this.price,
    required this.location,
    required this.availability,
    required this.imageUrl,
    required this.onTap,
  });

  Future<String> getCarStatus(String carId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await firestore
        .collection('rentedcars')
        .where('carId', isEqualTo: carId)
        .get();

    return querySnapshot.docs.isNotEmpty ? 'Rented' : 'Rentable';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Center(
            child: Container(
              height: 250,
              width: 300,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.circular(20),
                color: color2,
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.fill,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 2,
                    right: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: color1.withAlpha(50),
                        boxShadow: CupertinoContextMenu.kEndBoxShadow,
                      ),
                      child: Row(
                        children: [
                          Text(
                            price.toString(),
                            style: TextStyle(
                              color: color2,
                              fontFamily: "kanitm",
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          Icon(
                            Icons.euro,
                            color: color5,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color8,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                carName,
                style: const TextStyle(fontFamily: "degularb", fontSize: 16),
              ),
              Text(
                location,
                style: const TextStyle(fontFamily: "kanitm"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FutureBuilder<String>(
                    future:
                        getCarStatus(carId), // carId'yi burada elde etmelisiniz
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else {
                        return Text(
                          snapshot.data ?? 'Driveable',
                          style: TextStyle(fontFamily: "kanitm"),
                        );
                      }
                    },
                  ),
                  Icon(Icons.workspace_premium_outlined),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
