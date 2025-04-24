import '../utils/imports.dart';
import 'package:flutter/material.dart';

class AppSettings extends ChangeNotifier {
  String _theme = 'Light';
  String _calendarView = 'Week';
  String _fontSize = 'Medium';

  String get theme => _theme;
  String get calendarView => _calendarView;
  String get fontSize => _fontSize;

  bool get isDarkMode => _theme == 'Dark';

  double get fontSizeValue {
    switch (_fontSize) {
      case 'Small':
        return 12;
      case 'Medium':
        return 14;
      case 'Large':
        return 16;
      case 'Extra Large':
        return 18;
      default:
        return 14;
    }
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _theme = prefs.getString('theme') ?? 'Light';
    _fontSize = prefs.getString('fontSize') ?? 'Medium';
    notifyListeners();
  }

  Future<void> setTheme(String theme) async {
    _theme = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme);
    notifyListeners();
  }

  Future<void> setFontSize(String size) async {
    _fontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fontSize', size);
    notifyListeners();
  }
}
