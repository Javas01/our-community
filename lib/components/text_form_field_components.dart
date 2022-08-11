import 'package:flutter/material.dart';

class EmailField extends StatelessWidget {
  const EmailField({
    Key? key,
    required this.emailController,
  }) : super(key: key);

  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        autofocus: false,
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
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
        onSaved: (value) {
          emailController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
            prefixIcon: const Icon(Icons.email),
            contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
            hintText: 'Email',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))));
  }
}

class FormInputField extends StatelessWidget {
  const FormInputField({
    Key? key,
    required this.controller,
    required this.icon,
    required this.hintText,
    required this.isLast,
    this.validator,
    this.maxLength,
    this.keyboardType,
    this.minLines,
    this.maxLines,
    this.obscureText,
  }) : super(key: key);

  final TextEditingController controller;
  final Icon icon;
  final String hintText;
  final bool isLast;
  final bool? obscureText;
  final String? Function(String?)? validator;
  final int? maxLength, minLines, maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        keyboardType: keyboardType,
        minLines: minLines,
        maxLines: maxLines ?? 1,
        maxLength: maxLength,
        controller: controller,
        obscureText: obscureText ?? false,
        validator: validator ??
            (value) {
              if (value!.isEmpty) {
                return ('$hintText cannot be empty');
              }
              return null;
            },
        onSaved: (value) {
          controller.text = value!;
        },
        textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: icon,
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ));
  }
}

class FormSubmitButton extends StatelessWidget {
  const FormSubmitButton(
      {Key? key, required this.onPressed, required this.text})
      : super(key: key);

  final Function onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          fixedSize: const Size(500, 70)),

      // minWidth: MediaQuery.of(context).size.width,
      onPressed: () => onPressed(),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
