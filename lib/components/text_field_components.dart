import 'package:flutter/material.dart';

class CommentField extends StatelessWidget {
  const CommentField({
    Key? key,
    required this.commentController,
    required this.hintText,
    required this.contentPadding,
  }) : super(key: key);

  final TextEditingController commentController;
  final String hintText;
  final EdgeInsets contentPadding;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: commentController,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.chat_outlined),
        contentPadding: contentPadding,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
