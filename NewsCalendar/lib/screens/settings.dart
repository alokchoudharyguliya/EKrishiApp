import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Settings state variables
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  bool _dailyDigest = true;
  bool _breakingNewsAlerts = false;
  String _selectedTheme = 'System Default';
  String _selectedFontSize = 'Medium';
  String _selectedLanguage = 'English';
  String _selectedCalendarView = 'Week';
  bool _showThumbnails = true;
  bool _saveArticlesOffline = false;
  bool _analyticsEnabled = true;

  // News categories to toggle
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
    return Scaffold(
      appBar: AppBar(title: Text('Settings'), centerTitle: true, elevation: 0),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Appearance'),

            _buildThemeSelector(),
            _buildFontSizeSelector(),
            _buildDarkModeSwitch(),
            _buildSectionHeader('News Preferences'),

            _buildNewsCategories(),
            _buildThumbnailsSwitch(),
            _buildOfflineReadingSwitch(),
            _buildSectionHeader('Calendar Preferences'),

            _buildCalendarViewSelector(),
            _buildSectionHeader('Notifications'),

            _buildNotificationsSwitch(),
            _buildDailyDigestSwitch(),
            _buildBreakingNewsSwitch(),
            _buildSectionHeader('General'),
            _buildLanguageSelector(),

            _buildAnalyticsSwitch(),
            SizedBox(height: 30),
            _buildResetButton(),
            SizedBox(height: 20),
          ],
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

  Widget _buildDarkModeSwitch() {
    return ListTile(
      title: Text('Dark Mode'),
      trailing: SizedBox(
        width: 55,
        height: 30,
        child: FlutterSwitch(
          value: _darkMode,
          onToggle: (value) {
            setState(() {
              _darkMode = value;
            });
          },
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildThemeSelector() {
    return ListTile(
      title: Text('App Theme'),
      trailing: DropdownButton<String>(
        value: _selectedTheme,
        onChanged: (String? newValue) {
          setState(() {
            _selectedTheme = newValue!;
          });
        },
        items:
            <String>[
              'System Default',
              'Light',
              'Dark',
              'Custom',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
      ),
    );
  }

  Widget _buildFontSizeSelector() {
    return ListTile(
      title: Text('Font Size'),
      trailing: DropdownButton<String>(
        value: _selectedFontSize,
        onChanged: (String? newValue) {
          setState(() {
            _selectedFontSize = newValue!;
          });
        },
        items:
            <String>[
              'Small',
              'Medium',
              'Large',
              'Extra Large',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return ListTile(
      title: Text('Language'),
      trailing: DropdownButton<String>(
        value: _selectedLanguage,
        onChanged: (String? newValue) {
          setState(() {
            _selectedLanguage = newValue!;
          });
        },
        items:
            <String>[
              'English',
              'Spanish',
              'French',
              'German',
              'Chinese',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
      ),
    );
  }

  Widget _buildCalendarViewSelector() {
    return ListTile(
      title: Text('Default Calendar View'),
      trailing: DropdownButton<String>(
        value: _selectedCalendarView,
        onChanged: (String? newValue) {
          setState(() {
            _selectedCalendarView = newValue!;
          });
        },
        items:
            <String>[
              'Day',
              'Week',
              'Month',
              'Agenda',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
      ),
    );
  }

  Widget _buildNotificationsSwitch() {
    return ListTile(
      title: Text('Enable Notifications'),
      trailing: SizedBox(
        width: 55,
        height: 30,
        child: FlutterSwitch(
          value: _notificationsEnabled,
          onToggle: (value) {
            setState(() {
              _notificationsEnabled = value;
            });
          },
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildDailyDigestSwitch() {
    return ListTile(
      title: Text('Morning News Digest'),
      subtitle: Text('Receive a summary of top stories at 8 AM'),
      trailing: SizedBox(
        width: 55,
        height: 30,
        child: FlutterSwitch(
          value: _dailyDigest,
          onToggle: (value) {
            setState(() {
              _dailyDigest = value;
            });
          },
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildBreakingNewsSwitch() {
    return ListTile(
      title: Text('Breaking News Alerts'),
      subtitle: Text('Get immediate notifications for important news'),
      trailing: SizedBox(
        width: 55,
        height: 30,
        child: FlutterSwitch(
          value: _breakingNewsAlerts,
          onToggle: (value) {
            setState(() {
              _breakingNewsAlerts = value;
            });
          },
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildThumbnailsSwitch() {
    return ListTile(
      title: Text('Show Article Thumbnails'),
      trailing: SizedBox(
        width: 55,
        height: 30,
        child: FlutterSwitch(
          value: _showThumbnails,
          onToggle: (value) {
            setState(() {
              _showThumbnails = value;
            });
          },
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildOfflineReadingSwitch() {
    return ListTile(
      title: Text('Save Articles for Offline Reading'),
      subtitle: Text('Automatically save articles when on Wi-Fi'),
      trailing: SizedBox(
        width: 55,
        height: 30,
        child: FlutterSwitch(
          value: _saveArticlesOffline,
          onToggle: (value) {
            setState(() {
              _saveArticlesOffline = value;
            });
          },
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildAnalyticsSwitch() {
    return ListTile(
      title: Text('Share Analytics'),
      subtitle: Text('Help improve the app by sharing usage data'),
      trailing: SizedBox(
        width: 55,
        height: 30,
        child: FlutterSwitch(
          value: _analyticsEnabled,
          onToggle: (value) {
            setState(() {
              _analyticsEnabled = value;
            });
          },
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildNewsCategories() {
    return Column(
      children:
          newsCategories.entries.map((entry) {
            return CheckboxListTile(
              title: Text(entry.key),
              value: entry.value,
              onChanged: (bool? value) {
                setState(() {
                  newsCategories[entry.key] = value!;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            );
          }).toList(),
    );
  }

  Widget _buildResetButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Show confirmation dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Reset Settings'),
                content: Text(
                  'Are you sure you want to reset all settings to default?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      // Reset all settings
                      setState(() {
                        _darkMode = false;
                        _notificationsEnabled = true;
                        _dailyDigest = true;
                        _breakingNewsAlerts = false;
                        _selectedTheme = 'System Default';
                        _selectedFontSize = 'Medium';
                        _selectedLanguage = 'English';
                        _selectedCalendarView = 'Week';
                        _showThumbnails = true;
                        _saveArticlesOffline = false;
                        _analyticsEnabled = true;

                        // Reset all news categories to true
                        newsCategories.updateAll((key, value) => true);
                      });
                      Navigator.of(context).pop();
                    },
                    child: Text('Reset'),
                  ),
                ],
              );
            },
          );
        },
        style: ElevatedButton.styleFrom(
          // primary: Colors.red,
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        ),
        child: Text('Reset to Default', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
