import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:our_community/components/text_form_field_components.dart';
import 'package:our_community/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
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
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(36.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Image(
                  height: 200,
                  image: AssetImage('assets/community.jpg'),
                ),
                const SizedBox(height: 10),
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
                FormInputField(
                  controller: emailController,
                  validator: (value) {
                    bool emailValid = RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(value!);
                    if (value.isEmpty) {
                      return ('Email cannot be empty');
                    }
                    if (!emailValid) {
                      return ('Please enter a valid email');
                    }
                    return null;
                  },
                  hintText: 'Email',
                  isLast: false,
                  icon: const Icon(Icons.email),
                ),
                const SizedBox(height: 20),
                FormInputField(
                  controller: passwordController,
                  validator: (value) {
                    bool passwordValid = RegExp(r"^.{6,}$").hasMatch(value!);
                    if (value.isEmpty) {
                      return ('Password cannot be empty');
                    }
                    if (!passwordValid) {
                      return ('Password must be at least 6 characters');
                    }
                    return null;
                  },
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
                  validator: (String? value) {
                    if (value?.toUpperCase().trim() != 'ATLMASJID') {
                      return 'Incorrect community code';
                    }
                    return null;
                  },
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
                  text: 'Signup',
                ),
                const SizedBox(height: 20),
                const RegistrationSubtext(
                  text: 'Already have an Account? ',
                  linkText: 'Login',
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: _isChecked,
                      onChanged: (newValue) {
                        setState(() {
                          _isChecked = true;
                        });
                      },
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(text: 'Agree to ', children: [
                          TextSpan(
                            text: 'Terms and Conditions ',
                            style: const TextStyle(color: Colors.blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                final url = Uri.parse(
                                    'https://privacyterms.io/view/1nbUFdsr-KOxNJ8F0-zaIOkv/');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                } else {
                                  throw 'Could not launch $url';
                                }
                              },
                          ),
                          const TextSpan(text: 'and '),
                          TextSpan(
                            text: 'Privacy Policy ',
                            style: const TextStyle(color: Colors.blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                final url = Uri.parse(
                                    'https://privacyterms.io/view/VMK9NY83-GNckF1Jn-2e3RSD/');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                } else {
                                  throw 'Could not launch $url';
                                }
                              },
                          ),
                        ]),
                      ),
                    )
                  ],
                )
              ],
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
      if (_isChecked == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('You must agree to terms and conditions to register.'),
          ),
        );
        return;
      }

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
