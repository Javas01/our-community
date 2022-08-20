import 'package:flutter/material.dart';
import 'package:our_community/provider_test.dart';
import 'package:provider/provider.dart';

class CommentField extends StatefulWidget {
  const CommentField({
    Key? key,
    required this.commentController,
    required this.hintText,
    required this.unFocus,
    required this.focusNode,
  }) : super(key: key);

  final TextEditingController commentController;
  final String hintText;
  final VoidCallback unFocus;
  final FocusNode focusNode;

  @override
  State<CommentField> createState() => _CommentFieldState();
}

class _CommentFieldState extends State<CommentField> {
  bool _showClear = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
        child: Consumer<AddCommentModel>(
          builder: (context, value, child) {
            return TextField(
              focusNode: widget.focusNode,
              controller: widget.commentController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              style: const TextStyle(fontSize: 12, height: 1),
              onChanged: (content) {
                content != ''
                    ? setState(() {
                        _showClear = true;
                      })
                    : setState(() {
                        _showClear = false;
                      });
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.chat_outlined,
                  size: 20,
                ),
                hintText: value.isReply ? 'Reply to comment' : 'Reply to post',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: _showClear
                    ? IconButton(
                        onPressed: () {
                          widget.commentController.clear();
                          widget.unFocus();
                          setState(() {
                            _showClear = false;
                          });
                        },
                        icon: const Icon(
                          Icons.clear_rounded,
                        ),
                      )
                    : null,
              ),
            );
          },
        ));
  }
}
