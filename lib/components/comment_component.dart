import 'package:flutter/material.dart';

class UserComment extends StatelessWidget {
  const UserComment({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.commentText,
  }) : super(key: key);
  final String firstName, lastName, commentText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.account_circle),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$firstName $lastName',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 4),
                Text(commentText)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
