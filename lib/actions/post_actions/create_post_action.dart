import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:our_ummah/config.dart';
import 'package:our_ummah/models/post_model.dart';

void createPost(
  String title,
  String description,
  String type,
  String tag,
  File? image,
  BuildContext context,
  String userId,
) async {
  final posts = FirebaseFirestore.instance
      .collection('Communities')
      .doc(communityCode)
      .collection('Posts')
      .withConverter(
        fromFirestore: postFromFirestore,
        toFirestore: postToFirestore,
      );

  try {
    final newPost = Post(
      createdBy: userId,
      title: title,
      description: description,
      tags: [tag],
      type: type,
      timestamp: Timestamp.now(),
    );
    final postDocRef = await posts.add(newPost);
    if (image != null) {
      await FirebaseStorage.instance
          .ref('postPics')
          .child(postDocRef.id)
          .putFile(image);

      final imageUrl = await FirebaseStorage.instance
          .ref('postPics')
          .child(postDocRef.id)
          .getDownloadURL();

      postDocRef.update({'imageUrl': imageUrl});
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to create post: $e'),
      ),
    );
  }
}
