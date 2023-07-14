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
          .ref('postPics')
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
      'lastEdited': Timestamp.now(),
      ...imageUrl != null ? {'imageUrl': imageUrl} : {}
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Failed to edit post: ${e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim()}'),
      ),
    );
  }
}
