import 'dart:async';
import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const PdfToolkitApp());
  }, (error, stackTrace) {
    debugPrint('Uncaught app error: $error\n$stackTrace');
  });
}
