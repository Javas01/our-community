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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim()),
        ),
      );
    }
  }
}
