import 'package:flutter/material.dart';

class StaticTag extends StatefulWidget {
  const StaticTag({super.key, required this.title, required this.color});

  final String title;
  final Color color;

  @override
  State<StaticTag> createState() => _StaticTagState();
}

class _StaticTagState extends State<StaticTag> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(widget.title),
    );
  }
}
