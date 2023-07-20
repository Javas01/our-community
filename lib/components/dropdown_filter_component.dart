import 'package:flutter/material.dart';
import 'package:our_ummah/constants/filters.dart';
import 'package:our_ummah/extensions/string_extensions.dart';

class DropdownFilter extends StatelessWidget {
  const DropdownFilter({
    super.key,
    required this.filter,
    required this.value,
    required this.onChanged,
  });

  final EventFilter filter;
  final dynamic value;
  final Function(dynamic)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: value != null
              ? filter.color.withOpacity(0.7)
              : filter.color.withOpacity(0.3),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: DropdownButton<String>(
            hint: Text(filter.title),
            borderRadius: BorderRadius.circular(40),
            underline: Container(),
            icon: filter.icon,
            items: filter.options.map((value) {
              return DropdownMenuItem(
                value: value,
                child: Text(value.toTitleCase()),
              );
            }).toList(),
            value: value,
            style: const TextStyle(
              color: Color.fromARGB(255, 39, 165, 104),
              fontSize: 16,
            ),
            alignment: AlignmentDirectional.center,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
