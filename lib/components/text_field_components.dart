import 'package:flutter/material.dart';

class CommentField extends StatelessWidget {
  const CommentField({
    Key? key,
    required this.commentController,
  }) : super(key: key);

  final TextEditingController commentController;

  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: commentController,
        decoration: InputDecoration(
            prefixIcon: const Icon(Icons.chat_outlined),
            hintText: 'Reply',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))));
  }
}
