import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void deletePost(
    BuildContext context, String postId, VoidCallback onSuccess) async {
  try {
    FirebaseFirestore.instance
        .collection('Communities')
        .doc('')
        .collection('Posts')
        .doc(postId)
        .delete();

    onSuccess.call();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error deleting post $e'),
      ),
    );
  }
}
