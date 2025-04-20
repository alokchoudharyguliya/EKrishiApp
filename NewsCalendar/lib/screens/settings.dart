import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newscalendar/main.dart';

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
              _buildSectionHeader('Appearance'),
              _buildThemeSelector(settings),
              _buildFontSizeSelector(),
              _buildSectionHeader('News Preferences'),
              _buildNewsCategories(),
              _buildSectionHeader('General'),
              SizedBox(height: 30),
              _buildResetButton(settings),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildThemeSelector(AppSettings settings) {
    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.surface,
      child: ListTile(
        title: Text(
          'App Theme',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        trailing: DropdownButton<String>(
          value: settings.theme,
          dropdownColor: Theme.of(context).colorScheme.surface,
          onChanged: (String? newValue) {
            if (newValue != null) {
              settings.setTheme(newValue);
            }
          },
          items:
              ['Light', 'Dark'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildFontSizeSelector() {
    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.surface,
      child: ListTile(
        title: Text(
          'Font Size',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        trailing: DropdownButton<String>(
          value: _selectedFontSize,
          dropdownColor: Theme.of(context).colorScheme.surface,
          onChanged: (String? newValue) {
            setState(() {
              _selectedFontSize = newValue!;
              widget.onFontSizeChanged(newValue);
            });
            _savePreference('fontSize', newValue!);
          },
          items:
              [
                'Small',
                'Medium',
                'Large',
                'Extra Large',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildNewsCategories() {
    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children:
            newsCategories.entries.map((entry) {
              return CheckboxListTile(
                title: Text(
                  entry.key,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                value: entry.value,
                onChanged: (bool? value) {
                  setState(() {
                    newsCategories[entry.key] = value!;
                  });
                },
                activeColor: Theme.of(context).colorScheme.secondary,
                checkColor: Theme.of(context).colorScheme.onPrimary,
                controlAffinity: ListTileControlAffinity.leading,
              );
            }).toList(),
      ),
    );
  }

  Widget _buildResetButton(AppSettings settings) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.surface,
                title: Text(
                  'Reset Settings',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                content: Text(
                  'Are you sure you want to reset all settings to default?',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      setState(() {
                        newsCategories.updateAll((key, value) => true);
                      });
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Reset',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
        child: Text('Reset to Default'),
      ),
    );
  }

  Future<void> _savePreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }
}
