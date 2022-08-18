import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';

void unBlock(
  String blockedUserId,
  BuildContext context,
  VoidCallback onSuccess,
) async {
  final userDocRef = FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .withConverter(
        fromFirestore: userFromFirestore,
        toFirestore: userToFirestore,
      );
  try {
    final userDoc = await userDocRef.get();

    final user = userDoc.data() as AppUser;
    final blockedUsers = user.blockedUsers;
    blockedUsers.remove(blockedUserId);

    await userDocRef.update({
      'blockedUsers': blockedUsers,
    });

    onSuccess.call();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('failed to unblock user'),
        backgroundColor: Colors.red,
      ),
    );
    Future.error(e);
  }
}
