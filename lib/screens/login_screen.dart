import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:our_ummah/screens/home_screen.dart';
import 'package:our_ummah/screens/registration_screen.dart';
import 'package:our_ummah/actions/user_actions/sign_in_action.dart';
import 'package:our_ummah/components/registration_subtext_component.dart';
import 'package:our_ummah/components/text_form_field_components.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
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
                EmailField(emailController: emailController),
                const SizedBox(height: 20),
                FormInputField(
                  controller: passwordController,
                  icon: const Icon(Icons.password_rounded),
                  hintText: 'Password',
                  isLast: true,
                  isPassword: true,
                ),
                const SizedBox(height: 20),
                FormSubmitButton(
                  onPressed: () {
                    signIn(
                      context,
                      emailController.text,
                      passwordController.text,
                      _formKey,
                      () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: ((context) => const HomeScreen()),
                          ),
                          (route) => false,
                        );
                      },
                    );
                  },
                  text: 'Login',
                ),
                const SizedBox(height: 20),
                const RegistrationSubtext(
                  text: 'Dont have an Account? ',
                  linkText: 'Signup',
                  screen: RegistrationScreen(),
                ),
                TextButton(
                  onPressed: () {
                    if (emailController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Enter an email'),
                        ),
                      );
                      return;
                    }
                    FirebaseAuth.instance
                        .sendPasswordResetEmail(email: emailController.text)
                        .then((_) => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Reset email sent'),
                              ),
                            ))
                        .catchError((error, stackTrace) =>
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$error'),
                                backgroundColor: Colors.red,
                              ),
                            ));
                  },
                  child: const Text('Reset password'),
                )
              ],
            ),
          ),
        )),
      ),
    );
  }
}
