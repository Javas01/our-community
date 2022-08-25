import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:our_ummah/screens/OnboardingScreen/onboarding_screen.dart';

void logOut(BuildContext context) {
  FirebaseAuth.instance.signOut().then(
        (value) => {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: ((context) => const OnboardingScreen()),
            ),
            (route) => false,
          )
        },
      );
}
