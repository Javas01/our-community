import 'package:flutter/material.dart';

class AddCommentModel extends ChangeNotifier {
  bool _isReply = false;

  bool get isReply => _isReply;
  set isReply(bool newValue) {
    _isReply = newValue;
    notifyListeners();
  }
}
