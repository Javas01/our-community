import 'package:flutter/material.dart';

class CommentField extends StatefulWidget {
  const CommentField({
    Key? key,
    required this.commentController,
    required this.hintText,
    required this.unFocus,
    this.focus,
  }) : super(key: key);

  final TextEditingController commentController;
  final String hintText;
  final VoidCallback unFocus;
  final FocusNode? focus;

  @override
  State<CommentField> createState() => _CommentFieldState();
}

class _CommentFieldState extends State<CommentField> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
      child: TextField(
        focusNode: widget.focus,
        controller: widget.commentController,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        style: const TextStyle(fontSize: 12, height: 1),
        decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.chat_outlined,
            size: 20,
          ),
          hintText: widget.hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          suffixIcon: IconButton(
            onPressed: () {
              widget.commentController.clear();
              widget.unFocus();
            },
            icon: const Icon(
              Icons.clear_rounded,
            ),
          ),
        ),
      ),
    );
  }
}
