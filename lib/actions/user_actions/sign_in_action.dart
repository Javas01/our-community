import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void signIn(
  BuildContext context,
  String email,
  String password,
  GlobalKey<FormState> formKey,
  VoidCallback onSuccess,
) async {
  if (formKey.currentState!.validate()) {
    final auth = FirebaseAuth.instance;
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);

      onSuccess.call();
    } catch (e) {
      Future.error('failed to sign in $e');
    }
  }
}
