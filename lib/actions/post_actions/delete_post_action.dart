import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:our_ummah/models/community_model.dart';
import 'package:provider/provider.dart';

void deletePost(BuildContext context, String postId, String type,
    VoidCallback onSuccess) async {
  try {
    FirebaseFirestore.instance
        .collection('Communities')
        .doc(Provider.of<Community>(context, listen: false).id)
        .collection(type == 'business' ? 'Businesses' : 'Posts')
        .doc(postId)
        .delete();

    onSuccess.call();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Error deleting post ${e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim()}'),
      ),
    );
  }
}
