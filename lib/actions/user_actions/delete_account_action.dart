import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:our_community/screens/OnboardingScreen/onboarding_screen.dart';

void deleteAccount(BuildContext context) {
  final auth = FirebaseAuth.instance;
  showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Are you sure?'),
      content: const Text('This action cannot be undone.'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => auth.currentUser!.delete().then((_) {
            auth.signOut();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: ((context) => const OnboardingScreen()),
              ),
              (route) => false,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile deleted'),
              ),
            );
          }),
          child: const Text(
            'Delete',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}
