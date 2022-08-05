import 'package:flutter/material.dart';

class CommentField extends StatelessWidget {
  const CommentField({
    Key? key,
    required this.commentController,
    required this.focusNode,
  }) : super(key: key);

  final TextEditingController commentController;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: commentController,
        focusNode: focusNode,
        decoration: InputDecoration(
            prefixIcon: const Icon(Icons.chat_outlined),
            hintText: 'Reply',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))));
  }
}
