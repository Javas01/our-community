import 'package:flutter/material.dart';

class ResetCardModel extends ChangeNotifier {
  bool _shouldReset = false;

  void reset(bool shouldReset) {
    _shouldReset = shouldReset;
    notifyListeners();
  }

  bool get shouldReset => _shouldReset;
}
