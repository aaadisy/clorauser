import 'package:flutter/material.dart';

enum InputType {
  text,
  number,
  date,
  slider,
  singleSelect,
  multiSelect,
  yesNo,
}

class FuQuestion {
  final String key;
  final String question;
  final InputType type;
  final List<String>? options;
  final TextInputType keyboardType;

  FuQuestion({
    required this.key,
    required this.question,
    required this.type,
    this.options,
    TextInputType? keyboardType,
  }) : keyboardType = keyboardType ??
      (type == InputType.number
          ? TextInputType.number
          : type == InputType.date
          ? TextInputType.datetime
          : TextInputType.text);
}
