import 'package:flutter/material.dart';

class RecentFilesController extends ChangeNotifier {
  final List<Map<String, dynamic>> _recentFiles = [];

  List<Map<String, dynamic>> get recentFiles => List.unmodifiable(_recentFiles);

  void addFile(Map<String, dynamic> fileRecord) {
    _recentFiles.insert(0, fileRecord);
    notifyListeners();
  }
}
