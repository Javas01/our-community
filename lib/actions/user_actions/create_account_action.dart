import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:our_ummah/models/user_model.dart';

void createAccount(
  BuildContext context,
  String firstName,
  String lastName,
  String email,
  String password,
  String communityCode,
  GlobalKey<FormState> formKey,
  bool isChecked,
  VoidCallback onSuccess,
) async {
  if (formKey.currentState!.validate()) {
    final auth = FirebaseAuth.instance;
    if (isChecked == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must agree to terms and conditions to register.'),
        ),
      );
      return;
    }

    try {
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final newUser = AppUser(
        firstName: firstName,
        lastName: lastName,
        communityCodes: [communityCode.toLowerCase().trim()],
      );
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.uid)
          .withConverter(
            fromFirestore: userFromFirestore,
            toFirestore: userToFirestore,
          )
          .set(newUser);

      onSuccess.call();
    } catch (e) {
      Future.error('Create account failed: $e');
    }
  }
}
