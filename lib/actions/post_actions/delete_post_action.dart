import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:our_community/config.dart';

void deletePost(String postId, VoidCallback onSuccess) async {
  try {
    await FirebaseFirestore.instance
        .collection('Communities')
        .doc(communityCode)
        .collection('Posts')
        .doc(postId)
        .delete();

    onSuccess.call();
  } catch (e) {
    Future.error('Error deleting post $e');
  }
}
