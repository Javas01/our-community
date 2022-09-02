import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:our_ummah/models/user_model.dart';

void blockUser(
  BuildContext context,
  String userIdToBlock,
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
    final user = userDoc.data()!;
    final blockedUsers = user.blockedUsers;
    blockedUsers.add(userIdToBlock);

    userDocRef.update({
      'blockedUsers': blockedUsers,
    });

    onSuccess.call();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('failed to unblock user'),
      ),
    );
  }
}
