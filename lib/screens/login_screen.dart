import 'package:flutter/material.dart';
import 'package:our_community/screens/home_screen.dart';
import 'package:our_community/screens/registration_screen.dart';
import '../actions/user_actions/sign_in_action.dart';
import '../components/registration_subtext_component.dart';
import '../components/text_form_field_components.dart';

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
                  obscureText: true,
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
                )
              ],
            ),
          ),
        )),
      ),
    );
  }
}
