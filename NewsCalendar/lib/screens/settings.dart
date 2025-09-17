import 'package:flutter/material.dart';
import 'package:newscalendar/widgets/font_size_selector.dart';
import 'package:newscalendar/widgets/news_categories_card.dart';
import 'package:newscalendar/widgets/reset_button.dart';
import 'package:newscalendar/widgets/section_header.dart';
import 'package:newscalendar/widgets/theme_selector.dart';
import '../utils/imports.dart';

class SettingsPage extends StatefulWidget {
  final Function(String) onThemeChanged;
  final Function(String) onFontSizeChanged;
  const SettingsPage({
    Key? key,
    required this.onThemeChanged,
    required this.onFontSizeChanged,
  }) : super(key: key);
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedFontSize = 'Medium';
  Map<String, bool> newsCategories = {
    'Politics': true,
    'Technology': true,
    'Business': true,
    'Entertainment': true,
    'Sports': true,
    'Science': false,
    'Health': true,
  };
  Future<void> _savePreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.primary,
      ),
      body: Container(
        color: colorScheme.background,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: 'Appearance'), // custom widget
              ThemeSelector(
                // custom widget
                selectedTheme: settings.theme,
                onChanged: (newValue) {
                  settings.setTheme(newValue);
                  widget.onThemeChanged(newValue);
                },
              ),
              FontSizeSelector(
                // custom widget
                selectedFontSize: _selectedFontSize,
                onChanged: (newValue) {
                  setState(() {
                    _selectedFontSize = newValue;
                    widget.onFontSizeChanged(newValue);
                  });
                  _savePreference('fontSize', newValue);
                },
              ),
              // SectionHeader(title: 'News Preferences'), // custom widget
              // NewsCategoriesCard(
              //   // custom widget
              //   newsCategories: newsCategories,
              //   onChanged: (updated) {
              //     setState(() {
              //       newsCategories = updated;
              //     });
              //   },
              // ),
              SectionHeader(title: 'General'), // custom widget
              SizedBox(height: 30),
              ResetButton(
                // custom widget
                newsCategories: newsCategories,
                onCategoriesReset: () {
                  setState(() {});
                },
                onReset: () {
                  // Any additional reset logic if needed
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
