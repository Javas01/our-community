import 'package:flutter/material.dart';
import 'package:our_ummah/constants/tag_options.dart';
import 'package:our_ummah/models/post_model.dart';

class EventFilter {
  const EventFilter({
    required this.title,
    required this.onChanged,
    required this.color,
    required this.options,
    required this.hint,
    required this.icon,
    required this.label,
  });

  final dynamic title;
  final void Function(dynamic)? onChanged;
  final Color color;
  final List<String> options;
  final String hint;
  final Icon icon;
  final String label;

  @override
  String toString() {
    return 'EventFilter(title: $title, onChanged: $onChanged, color: $color, options: $options, hint: $hint, icon: $icon, label: $label)';
  }
}

final List<EventFilter> eventFilters = [
  EventFilter(
    title: 'Audience',
    onChanged: (dynamic) {},
    color: Colors.redAccent,
    options: Audience.values.map((e) => e.name).toList(),
    hint: 'hint',
    icon: const Icon(Icons.filter_list_rounded),
    label: 'label',
  ),
  EventFilter(
    title: 'Distance',
    onChanged: (dynamic) {},
    color: Colors.orangeAccent,
    options: [
      '10',
      '25',
      '50',
      '100',
      '500',
    ],
    hint: 'hint',
    icon: const Icon(Icons.filter_list_rounded),
    label: 'label',
  ),
  EventFilter(
    title: 'Price',
    onChanged: (dynamic) {},
    color: Colors.greenAccent,
    options: Price.values.map((e) => e.name).toList(),
    hint: 'hint',
    icon: const Icon(Icons.filter_list_rounded),
    label: 'label',
  ),
  EventFilter(
    title: 'Category',
    onChanged: (dynamic) {},
    color: Colors.deepPurpleAccent,
    options: eventOptionsList.map((e) => e.keys.first).toList(),
    hint: 'hint',
    icon: const Icon(Icons.filter_list_rounded),
    label: 'label',
  ),
];
