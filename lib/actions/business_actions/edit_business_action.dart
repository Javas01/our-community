import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:our_ummah/models/business_model.dart';
import 'package:our_ummah/models/community_model.dart';
import 'package:provider/provider.dart';

void editBusiness(
  String title,
  String description,
  String address,
  String phoneNumber,
  List<String> tags,
  File? image,
  BuildContext context,
  String businessId,
) async {
  final businesses = FirebaseFirestore.instance
      .collection('Communities')
      .doc(Provider.of<Community>(context, listen: false).id)
      .collection('Businesses')
      .withConverter(
        fromFirestore: businessFromFirestore,
        toFirestore: businessToFirestore,
      );

  try {
    String? imageUrl;
    if (image != null) {
      await FirebaseStorage.instance
          .ref('businessPics')
          .child(businessId)
          .putFile(image);

      imageUrl = await FirebaseStorage.instance
          .ref('businessPics')
          .child(businessId)
          .getDownloadURL();
    }
    businesses.doc(businessId).update({
      'title': title,
      'description': description,
      'address': address,
      'phoneNumber': phoneNumber,
      'tags': tags,
      'lastEdited': Timestamp.now(),
      ...imageUrl != null ? {'businessLogoUrl': imageUrl} : {}
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Failed to edit business: ${e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim()}'),
      ),
    );
  }
}
