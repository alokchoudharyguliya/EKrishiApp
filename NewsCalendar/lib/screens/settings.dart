// // import 'package:flutter/material.dart';
// // import 'package:flutter_switch/flutter_switch.dart';

// // class SettingsPage extends StatefulWidget {
// //   @override
// //   _SettingsPageState createState() => _SettingsPageState();
// // }

// // class _SettingsPageState extends State<SettingsPage> {
// //   // Settings state variables
// //   bool _darkMode = false;
// //   bool _notificationsEnabled = true;
// //   bool _dailyDigest = true;
// //   bool _breakingNewsAlerts = false;
// //   String _selectedTheme = 'System Default';
// //   String _selectedFontSize = 'Medium';
// //   String _selectedLanguage = 'English';
// //   String _selectedCalendarView = 'Week';
// //   bool _showThumbnails = true;
// //   bool _saveArticlesOffline = false;
// //   bool _analyticsEnabled = true;

// //   // News categories to toggle
// //   Map<String, bool> newsCategories = {
// //     'Politics': true,
// //     'Technology': true,
// //     'Business': true,
// //     'Entertainment': true,
// //     'Sports': true,
// //     'Science': false,
// //     'Health': true,
// //   };

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text('Settings'), centerTitle: true, elevation: 0),
// //       body: SingleChildScrollView(
// //         padding: EdgeInsets.all(16.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             _buildSectionHeader('Appearance'),

// //             _buildThemeSelector(),
// //             _buildFontSizeSelector(),
// //             _buildDarkModeSwitch(),
// //             _buildSectionHeader('News Preferences'),

// //             _buildNewsCategories(),
// //             _buildThumbnailsSwitch(),
// //             _buildOfflineReadingSwitch(),
// //             _buildSectionHeader('Calendar Preferences'),

// //             _buildCalendarViewSelector(),
// //             _buildSectionHeader('Notifications'),

// //             _buildNotificationsSwitch(),
// //             _buildDailyDigestSwitch(),
// //             _buildBreakingNewsSwitch(),
// //             _buildSectionHeader('General'),
// //             _buildLanguageSelector(),

// //             _buildAnalyticsSwitch(),
// //             SizedBox(height: 30),
// //             _buildResetButton(),
// //             SizedBox(height: 20),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildSectionHeader(String title) {
// //     return Padding(
// //       padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
// //       child: Text(
// //         title,
// //         style: TextStyle(
// //           fontSize: 18,
// //           fontWeight: FontWeight.bold,
// //           color: Theme.of(context).colorScheme.primary,
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildDarkModeSwitch() {
// //     return ListTile(
// //       title: Text('Dark Mode'),
// //       trailing: SizedBox(
// //         width: 55,
// //         height: 30,
// //         child: FlutterSwitch(
// //           value: _darkMode,
// //           onToggle: (value) {
// //             setState(() {
// //               _darkMode = value;
// //             });
// //           },
// //           activeColor: Theme.of(context).colorScheme.primary,
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildThemeSelector() {
// //     return ListTile(
// //       title: Text('App Theme'),
// //       trailing: DropdownButton<String>(
// //         value: _selectedTheme,
// //         onChanged: (String? newValue) {
// //           setState(() {
// //             _selectedTheme = newValue!;
// //           });
// //         },
// //         items:
// //             <String>[
// //               'System Default',
// //               'Light',
// //               'Dark',
// //               'Custom',
// //             ].map<DropdownMenuItem<String>>((String value) {
// //               return DropdownMenuItem<String>(value: value, child: Text(value));
// //             }).toList(),
// //       ),
// //     );
// //   }

// //   Widget _buildFontSizeSelector() {
// //     return ListTile(
// //       title: Text('Font Size'),
// //       trailing: DropdownButton<String>(
// //         value: _selectedFontSize,
// //         onChanged: (String? newValue) {
// //           setState(() {
// //             _selectedFontSize = newValue!;
// //           });
// //         },
// //         items:
// //             <String>[
// //               'Small',
// //               'Medium',
// //               'Large',
// //               'Extra Large',
// //             ].map<DropdownMenuItem<String>>((String value) {
// //               return DropdownMenuItem<String>(value: value, child: Text(value));
// //             }).toList(),
// //       ),
// //     );
// //   }

// //   Widget _buildLanguageSelector() {
// //     return ListTile(
// //       title: Text('Language'),
// //       trailing: DropdownButton<String>(
// //         value: _selectedLanguage,
// //         onChanged: (String? newValue) {
// //           setState(() {
// //             _selectedLanguage = newValue!;
// //           });
// //         },
// //         items:
// //             <String>[
// //               'English',
// //               'Spanish',
// //               'French',
// //               'German',
// //               'Chinese',
// //             ].map<DropdownMenuItem<String>>((String value) {
// //               return DropdownMenuItem<String>(value: value, child: Text(value));
// //             }).toList(),
// //       ),
// //     );
// //   }

// //   Widget _buildCalendarViewSelector() {
// //     return ListTile(
// //       title: Text('Default Calendar View'),
// //       trailing: DropdownButton<String>(
// //         value: _selectedCalendarView,
// //         onChanged: (String? newValue) {
// //           setState(() {
// //             _selectedCalendarView = newValue!;
// //           });
// //         },
// //         items:
// //             <String>[
// //               'Day',
// //               'Week',
// //               'Month',
// //               'Agenda',
// //             ].map<DropdownMenuItem<String>>((String value) {
// //               return DropdownMenuItem<String>(value: value, child: Text(value));
// //             }).toList(),
// //       ),
// //     );
// //   }

// //   Widget _buildNotificationsSwitch() {
// //     return ListTile(
// //       title: Text('Enable Notifications'),
// //       trailing: SizedBox(
// //         width: 55,
// //         height: 30,
// //         child: FlutterSwitch(
// //           value: _notificationsEnabled,
// //           onToggle: (value) {
// //             setState(() {
// //               _notificationsEnabled = value;
// //             });
// //           },
// //           activeColor: Theme.of(context).colorScheme.primary,
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildDailyDigestSwitch() {
// //     return ListTile(
// //       title: Text('Morning News Digest'),
// //       subtitle: Text('Receive a summary of top stories at 8 AM'),
// //       trailing: SizedBox(
// //         width: 55,
// //         height: 30,
// //         child: FlutterSwitch(
// //           value: _dailyDigest,
// //           onToggle: (value) {
// //             setState(() {
// //               _dailyDigest = value;
// //             });
// //           },
// //           activeColor: Theme.of(context).colorScheme.primary,
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildBreakingNewsSwitch() {
// //     return ListTile(
// //       title: Text('Breaking News Alerts'),
// //       subtitle: Text('Get immediate notifications for important news'),
// //       trailing: SizedBox(
// //         width: 55,
// //         height: 30,
// //         child: FlutterSwitch(
// //           value: _breakingNewsAlerts,
// //           onToggle: (value) {
// //             setState(() {
// //               _breakingNewsAlerts = value;
// //             });
// //           },
// //           activeColor: Theme.of(context).colorScheme.primary,
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildThumbnailsSwitch() {
// //     return ListTile(
// //       title: Text('Show Article Thumbnails'),
// //       trailing: SizedBox(
// //         width: 55,
// //         height: 30,
// //         child: FlutterSwitch(
// //           value: _showThumbnails,
// //           onToggle: (value) {
// //             setState(() {
// //               _showThumbnails = value;
// //             });
// //           },
// //           activeColor: Theme.of(context).colorScheme.primary,
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildOfflineReadingSwitch() {
// //     return ListTile(
// //       title: Text('Save Articles for Offline Reading'),
// //       subtitle: Text('Automatically save articles when on Wi-Fi'),
// //       trailing: SizedBox(
// //         width: 55,
// //         height: 30,
// //         child: FlutterSwitch(
// //           value: _saveArticlesOffline,
// //           onToggle: (value) {
// //             setState(() {
// //               _saveArticlesOffline = value;
// //             });
// //           },
// //           activeColor: Theme.of(context).colorScheme.primary,
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildAnalyticsSwitch() {
// //     return ListTile(
// //       title: Text('Share Analytics'),
// //       subtitle: Text('Help improve the app by sharing usage data'),
// //       trailing: SizedBox(
// //         width: 55,
// //         height: 30,
// //         child: FlutterSwitch(
// //           value: _analyticsEnabled,
// //           onToggle: (value) {
// //             setState(() {
// //               _analyticsEnabled = value;
// //             });
// //           },
// //           activeColor: Theme.of(context).colorScheme.primary,
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildNewsCategories() {
// //     return Column(
// //       children:
// //           newsCategories.entries.map((entry) {
// //             return CheckboxListTile(
// //               title: Text(entry.key),
// //               value: entry.value,
// //               onChanged: (bool? value) {
// //                 setState(() {
// //                   newsCategories[entry.key] = value!;
// //                 });
// //               },
// //               controlAffinity: ListTileControlAffinity.leading,
// //             );
// //           }).toList(),
// //     );
// //   }

// //   Widget _buildResetButton() {
// //     return Center(
// //       child: ElevatedButton(
// //         onPressed: () {
// //           // Show confirmation dialog
// //           showDialog(
// //             context: context,
// //             builder: (BuildContext context) {
// //               return AlertDialog(
// //                 title: Text('Reset Settings'),
// //                 content: Text(
// //                   'Are you sure you want to reset all settings to default?',
// //                 ),
// //                 actions: [
// //                   TextButton(
// //                     onPressed: () => Navigator.of(context).pop(),
// //                     child: Text('Cancel'),
// //                   ),
// //                   TextButton(
// //                     onPressed: () {
// //                       // Reset all settings
// //                       setState(() {
// //                         _darkMode = false;
// //                         _notificationsEnabled = true;
// //                         _dailyDigest = true;
// //                         _breakingNewsAlerts = false;
// //                         _selectedTheme = 'System Default';
// //                         _selectedFontSize = 'Medium';
// //                         _selectedLanguage = 'English';
// //                         _selectedCalendarView = 'Week';
// //                         _showThumbnails = true;
// //                         _saveArticlesOffline = false;
// //                         _analyticsEnabled = true;

// //                         // Reset all news categories to true
// //                         newsCategories.updateAll((key, value) => true);
// //                       });
// //                       Navigator.of(context).pop();
// //                     },
// //                     child: Text('Reset'),
// //                   ),
// //                 ],
// //               );
// //             },
// //           );
// //         },
// //         style: ElevatedButton.styleFrom(
// //           // primary: Colors.red,
// //           padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
// //         ),
// //         child: Text('Reset to Default', style: TextStyle(color: Colors.white)),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:flutter_switch/flutter_switch.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:newscalendar/main.dart';

// class SettingsPage extends StatefulWidget {
//   @override
//   _SettingsPageState createState() => _SettingsPageState();
// }

// class _SettingsPageState extends State<SettingsPage> {
//   // News categories to toggle
//   Map<String, bool> newsCategories = {
//     'Politics': true,
//     'Technology': true,
//     'Business': true,
//     'Entertainment': true,
//     'Sports': true,
//     'Science': false,
//     'Health': true,
//   };

//   @override
//   Widget build(BuildContext context) {
//     final settings = Provider.of<AppSettings>(context, listen: false);

//     return Scaffold(
//       appBar: AppBar(title: Text('Settings'), centerTitle: true, elevation: 0),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildSectionHeader('Appearance'),
//             _buildThemeSelector(settings),
//             _buildFontSizeSelector(),
//             _buildDarkModeSwitch(settings),

//             _buildSectionHeader('News Preferences'),
//             _buildNewsCategories(),
//             _buildThumbnailsSwitch(),

//             _buildSectionHeader('Calendar Preferences'),
//             _buildCalendarViewSelector(settings),

//             _buildSectionHeader('General'),
//             _buildLanguageSelector(),

//             SizedBox(height: 30),
//             _buildResetButton(settings),
//             SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionHeader(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
//       child: Text(
//         title,
//         style: TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//           color: Theme.of(context).colorScheme.primary,
//         ),
//       ),
//     );
//   }

//   Widget _buildDarkModeSwitch(AppSettings settings) {
//     return ListTile(
//       title: Text('Dark Mode'),
//       trailing: FlutterSwitch(
//         value: settings.darkMode,
//         onToggle: (value) {
//           settings.setDarkMode(value);
//         },
//         activeColor: Theme.of(context).colorScheme.primary,
//       ),
//     );
//   }

//   Widget _buildThemeSelector(AppSettings settings) {
//     return ListTile(
//       title: Text('App Theme'),
//       trailing: DropdownButton<String>(
//         value: settings.darkMode ? 'Dark' : 'Light',
//         onChanged: (String? newValue) {
//           if (newValue == 'Dark') {
//             settings.setDarkMode(true);
//           } else if (newValue == 'Light') {
//             settings.setDarkMode(false);
//           }
//         },
//         items:
//             ['Light', 'Dark'].map<DropdownMenuItem<String>>((String value) {
//               return DropdownMenuItem<String>(value: value, child: Text(value));
//             }).toList(),
//       ),
//     );
//   }

//   Widget _buildFontSizeSelector() {
//     return ListTile(
//       title: Text('Font Size'),
//       trailing: DropdownButton<String>(
//         value: 'Medium', // You would get this from your settings
//         onChanged: (String? newValue) {
//           // Implement font size change
//         },
//         items:
//             [
//               'Small',
//               'Medium',
//               'Large',
//               'Extra Large',
//             ].map<DropdownMenuItem<String>>((String value) {
//               return DropdownMenuItem<String>(value: value, child: Text(value));
//             }).toList(),
//       ),
//     );
//   }

//   Widget _buildLanguageSelector() {
//     return ListTile(
//       title: Text('Language'),
//       trailing: DropdownButton<String>(
//         value: 'English', // Default language
//         onChanged: (String? newValue) {
//           // Implement language change
//         },
//         items:
//             [
//               'English',
//               'Spanish',
//               'French',
//               'German',
//               'Chinese',
//             ].map<DropdownMenuItem<String>>((String value) {
//               return DropdownMenuItem<String>(value: value, child: Text(value));
//             }).toList(),
//       ),
//     );
//   }

//   Widget _buildCalendarViewSelector(AppSettings settings) {
//     return ListTile(
//       title: Text('Default Calendar View'),
//       trailing: DropdownButton<String>(
//         value: settings.calendarView,
//         onChanged: (String? newValue) {
//           if (newValue != null) {
//             settings.setCalendarView(newValue);
//           }
//         },
//         items:
//             ['Day', 'Week', 'Month', 'Agenda'].map<DropdownMenuItem<String>>((
//               String value,
//             ) {
//               return DropdownMenuItem<String>(value: value, child: Text(value));
//             }).toList(),
//       ),
//     );
//   }

//   Widget _buildThumbnailsSwitch() {
//     return ListTile(
//       title: Text('Show Article Thumbnails'),
//       trailing: FlutterSwitch(
//         value: true, // You would get this from your settings
//         onToggle: (value) {
//           // Implement thumbnail visibility change
//         },
//         activeColor: Theme.of(context).colorScheme.primary,
//       ),
//     );
//   }

//   Widget _buildNewsCategories() {
//     return Column(
//       children:
//           newsCategories.entries.map((entry) {
//             return CheckboxListTile(
//               title: Text(entry.key),
//               value: entry.value,
//               onChanged: (bool? value) {
//                 setState(() {
//                   newsCategories[entry.key] = value!;
//                 });
//               },
//               controlAffinity: ListTileControlAffinity.leading,
//             );
//           }).toList(),
//     );
//   }

//   Widget _buildResetButton(AppSettings settings) {
//     return Center(
//       child: ElevatedButton(
//         onPressed: () {
//           showDialog(
//             context: context,
//             builder: (BuildContext context) {
//               return AlertDialog(
//                 title: Text('Reset Settings'),
//                 content: Text(
//                   'Are you sure you want to reset all settings to default?',
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.of(context).pop(),
//                     child: Text('Cancel'),
//                   ),
//                   TextButton(
//                     onPressed: () async {
//                       // Reset all settings
//                       final prefs = await SharedPreferences.getInstance();
//                       await prefs.clear();

//                       settings.setDarkMode(false);
//                       settings.setCalendarView('Week');

//                       setState(() {
//                         newsCategories.updateAll((key, value) => true);
//                       });

//                       Navigator.of(context).pop();
//                     },
//                     child: Text('Reset'),
//                   ),
//                 ],
//               );
//             },
//           );
//         },
//         child: Text('Reset to Default'),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newscalendar/main.dart';

class SettingsPage extends StatefulWidget {
  final Function(bool) onThemeChanged;
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
  // News categories to toggle

  String _selectedFontSize = 'Medium';
  bool _darkMode = false;
  // String _selectedLanguage = 'English';
  bool _showThumbnails = true;
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

    return Scaffold(
      appBar: AppBar(title: Text('Settings'), centerTitle: true, elevation: 0),
      body:
      // Center(),
      SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Appearance'),
            _buildThemeSelector(settings),
            _buildFontSizeSelector(),

            // _buildDarkModeSwitch(settings),
            _buildSectionHeader('News Preferences'),
            _buildNewsCategories(),

            //       _buildThumbnailsSwitch(),
            _buildSectionHeader('General'),
            //       _buildLanguageSelector(),
            SizedBox(height: 30),
            _buildResetButton(settings),
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

  Widget _buildDarkModeSwitch(AppSettings settings) {
    return ListTile(
      title: Text('Dark Mode'),
      trailing: FlutterSwitch(
        value: settings.darkMode,
        onToggle: (value) {
          settings.setDarkMode(value);
        },
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildThemeSelector(AppSettings settings) {
    return ListTile(
      title: Text('App Theme'),
      trailing: DropdownButton<String>(
        value: settings.darkMode ? 'Dark' : 'Light',
        onChanged: (String? newValue) {
          if (newValue == 'Dark') {
            settings.setDarkMode(true);
          } else if (newValue == 'Light') {
            settings.setDarkMode(false);
          }
        },
        items:
            ['Light', 'Dark'].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
      ),
    );
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
      _selectedFontSize = prefs.getString('fontSize') ?? 'Medium';
      _showThumbnails = prefs.getBool('showThumbnails') ?? true;
      // Load other preferences similarly
    });
  }

  Future<void> _savePreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  Widget _buildFontSizeSelector() {
    return ListTile(
      title: Text('Font Size'),
      trailing: DropdownButton<String>(
        value: _selectedFontSize,
        onChanged: (String? newValue) {
          setState(() {
            _selectedFontSize = newValue!;
            widget.onFontSizeChanged(newValue!);
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
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return ListTile(
      title: Text('Language'),
      trailing: DropdownButton<String>(
        value: 'English', // Default language
        onChanged: (String? newValue) {
          // Implement language change
        },
        items:
            [
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

  Widget _buildThumbnailsSwitch() {
    return ListTile(
      title: Text('Show Article Thumbnails'),
      trailing: FlutterSwitch(
        value: true, // You would get this from your settings
        onToggle: (value) {
          // Implement thumbnail visibility change
        },
        activeColor: Theme.of(context).colorScheme.primary,
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

  Widget _buildResetButton(AppSettings settings) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
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
                    onPressed: () async {
                      // Reset all settings
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();

                      settings.setDarkMode(false);

                      setState(() {
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
        child: Text('Reset to Default'),
      ),
    );
  }
}
