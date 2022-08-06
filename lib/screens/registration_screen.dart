import 'package:flutter/material.dart';
import 'package:our_community/components/text_form_field_components.dart';
import 'package:our_community/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/registration_subtext_component.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController communityController = TextEditingController();

  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
            child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 200,
                    child: Image.asset(
                      'assets/community.jpg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  FormInputField(
                    controller: firstNameController,
                    icon: const Icon(Icons.person),
                    hintText: 'First name',
                    isLast: false,
                  ),
                  const SizedBox(height: 20),
                  FormInputField(
                    controller: lastNameController,
                    icon: const Icon(Icons.person),
                    hintText: 'Last name',
                    isLast: false,
                  ),
                  const SizedBox(height: 20),
                  EmailField(emailController: emailController),
                  const SizedBox(height: 20),
                  FormInputField(
                    controller: passwordController,
                    icon: const Icon(Icons.password_rounded),
                    hintText: 'Password',
                    isLast: false,
                  ),
                  const SizedBox(height: 20),
                  FormInputField(
                    controller: communityController,
                    icon: const Icon(Icons.lock),
                    hintText: 'Community code',
                    isLast: true,
                  ),
                  const SizedBox(height: 20),
                  FormSubmitButton(
                      onPressed: () {
                        createAccount(
                          firstNameController.text,
                          lastNameController.text,
                          emailController.text,
                          passwordController.text,
                          communityController.text,
                        );
                      },
                      text: 'Signup'),
                  const SizedBox(height: 20),
                  const RegistrationSubtext(
                      text: 'Already have an Account? ', linkText: 'Login')
                ],
              ),
            ),
          ),
        )),
      ),
    );
  }

  void createAccount(
    String firstName,
    String lastName,
    String email,
    String password,
    String communityCode,
  ) async {
    print('TODO: Store community code');
    if (_formKey.currentState!.validate()) {
      String displayName = '$firstName $lastName';

      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) => {
                value.user!
                    .updateDisplayName(displayName)
                    .then((_) => {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => const HomeScreen())),
                              (route) => false)
                        })
                    .catchError((error) => Future.error(error))
              })
          .catchError((error) => {Future.error(error)});
    }
  }
}
