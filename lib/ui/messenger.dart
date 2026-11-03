import 'package:flutter/material.dart';

/// Root messenger: a message shown here survives the navigation that follows it.
final messengerKey = GlobalKey<ScaffoldMessengerState>();

void showToast(String text) {
  messengerKey.currentState
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text), duration: const Duration(seconds: 5)));
}
