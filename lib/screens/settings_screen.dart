import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:our_community/components/text_form_field_components.dart';
import 'package:our_community/screens/OnboardingScreen/onboarding_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _auth = FirebaseAuth.instance;
  final firstName =
      FirebaseAuth.instance.currentUser!.displayName?.split(' ')[0];
  final lastName =
      FirebaseAuth.instance.currentUser!.displayName?.split(' ')[1];

  final _formKey = GlobalKey<FormState>();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Center(
            child: Icon(
          Icons.account_circle_rounded,
          size: 200,
        )),
        Form(
          key: _formKey,
          child: Row(
            children: <Widget>[
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: NameField(
                  nameController: firstNameController,
                  hintText: firstName ?? 'First Name',
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: NameField(
                  nameController: lastNameController,
                  hintText: lastName ?? 'Last Name',
                ),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FormSubmitButton(
              onPressed: () {
                updateProfile(
                    firstNameController.text, lastNameController.text);
              },
              text: 'Update Profile'),
        ),
        const Spacer(),
        Center(
            child: ElevatedButton(
                onPressed: () {
                  logOut();
                },
                child: const Text('Log out')))
      ],
    );
  }

  void logOut() async {
    await _auth.signOut().then((value) => {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: ((context) => const OnboardingScreen())),
              (route) => false)
        });
  }

  void updateProfile(String firstName, String lastName) {
    if (_formKey.currentState!.validate()) {
      String displayName = '$firstName $lastName';
      const snackBar = SnackBar(content: Text('Profile updated successfully'));

      _auth.currentUser!
          .updateDisplayName(displayName)
          .then((_) => ScaffoldMessenger.of(context).showSnackBar(snackBar));
    }
  }
}
