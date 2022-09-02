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

class FormInputField extends StatefulWidget {
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
    this.isPassword,
  }) : super(key: key);

  final TextEditingController controller;
  final Icon icon;
  final String hintText;
  final bool isLast;
  final bool? isPassword;
  final String? Function(String?)? validator;
  final int? maxLength, minLines, maxLines;
  final TextInputType? keyboardType;

  @override
  State<FormInputField> createState() => _FormInputFieldState();
}

class _FormInputFieldState extends State<FormInputField> {
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        keyboardType: widget.keyboardType,
        minLines: widget.minLines,
        maxLines: widget.maxLines ?? 1,
        maxLength: widget.maxLength,
        controller: widget.controller,
        obscureText: widget.isPassword != null ? !_passwordVisible : false,
        validator: widget.validator ??
            (value) {
              if (value!.isEmpty) {
                return ('${widget.hintText} cannot be empty');
              }
              return null;
            },
        onSaved: (value) {
          widget.controller.text = value!;
        },
        textInputAction:
            widget.isLast ? TextInputAction.done : TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: widget.icon,
          suffixIcon: widget.isPassword != null
              ? IconButton(
                  icon: Icon(
                    // Based on passwordVisible state choose the icon
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Theme.of(context).primaryColorDark,
                  ),
                  onPressed: () {
                    // Update the state i.e. toogle the state of passwordVisible variable
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                )
              : null,
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: widget.hintText,
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
