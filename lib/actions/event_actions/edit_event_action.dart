import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:our_ummah/models/community_model.dart';
import 'package:our_ummah/models/post_model.dart';
import 'package:provider/provider.dart';

void editEvent(
  String title,
  String description,
  PostType type,
  List<String> tags,
  Audience audience,
  Price price,
  DateTime startDate,
  DateTime endDate,
  String location,
  File? image,
  BuildContext context,
  String postId,
) async {
  final posts = FirebaseFirestore.instance
      .collection('Communities')
      .doc(Provider.of<Community>(context, listen: false).id)
      .collection('Posts')
      .withConverter(
        fromFirestore: postFromFirestore,
        toFirestore: postToFirestore,
      );

  try {
    String? imageUrl;
    if (image != null) {
      await FirebaseStorage.instance
          .ref('postPics')
          .child(postId)
          .putFile(image);

      imageUrl = await FirebaseStorage.instance
          .ref('postPics')
          .child(postId)
          .getDownloadURL();
    }
    posts.doc(postId).update({
      'title': title,
      'description': description,
      'type': type.name,
      'tags': tags,
      'audience': audience,
      'price': price,
      'startDate': startDate,
      'endDate': endDate,
      'location': location,
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
