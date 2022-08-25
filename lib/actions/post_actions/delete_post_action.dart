import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:our_ummah/config.dart';

void deletePost(
    BuildContext context, String postId, VoidCallback onSuccess) async {
  try {
    FirebaseFirestore.instance
        .collection('Communities')
        .doc(communityCode)
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
