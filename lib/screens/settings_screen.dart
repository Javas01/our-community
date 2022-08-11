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
          ),
        ),
        Form(
          key: _formKey,
          child: Row(
            children: <Widget>[
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: FormInputField(
                  controller: firstNameController,
                  hintText: firstName ?? 'First Name',
                  icon: const Icon(Icons.person),
                  isLast: false,
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: FormInputField(
                  controller: lastNameController,
                  hintText: lastName ?? 'Last Name',
                  icon: const Icon(Icons.person),
                  isLast: true,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                logOut();
              },
              child: const Text('Log out'),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red),
              ),
              onPressed: () {
                deleteAccount();
              },
              child: const Text('Delete Account'),
            ),
          ],
        )
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

  void deleteAccount() {
    const snackBar = SnackBar(content: Text('Profile deleted'));

    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('This action cannot be undone.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _auth.currentUser!.delete().then((_) {
              _auth.signOut();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: ((context) => const OnboardingScreen())),
                  (route) => false);
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
}
