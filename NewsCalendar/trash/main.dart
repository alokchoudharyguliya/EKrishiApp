// class UserService with ChangeNotifier {
//   final FlutterSecureStorage _storage = FlutterSecureStorage();
//   Map<String, dynamic>? cachedUserData;

//   Future<String?> getUserId() async {
//     return await _storage.read(key: 'userId');
//   }

//   Future<void> setUserId(String userId) async {
//     await _storage.write(key: 'userId', value: userId);
//   }

//   Future<void> cacheUserData(Map<String, dynamic> data) async {
//     cachedUserData = data;
//     await _saveUserDataToSecureStorage(data); // Save to secure storage
//     notifyListeners();
//   }

//   Future<void> _saveUserDataToSecureStorage(
//     Map<String, dynamic> userData,
//   ) async {
//     try {
//       await _storage.write(key: 'userData', value: json.encode(userData));
//     } catch (e) {
//       print('Error saving to secure storage: $e');
//     }
//   }

//   Future<Map<String, dynamic>?> getUserData() async {
//     // First check memory cache
//     if (cachedUserData != null) return cachedUserData;

//     // If not in cache, check secure storage
//     final userDataString = await _storage.read(key: 'userData');
//     // print("${userDataString}---------------------");
//     if (userDataString != null) {
//       cachedUserData = jsonDecode(userDataString); // Convert back to Map
//       return jsonDecode(userDataString);
//     }
//     return null; // No data available
//   }

//   Future<void> clearUserData() async {
//     await _storage.delete(key: 'userId');
//     await _storage.delete(key: 'userEmail');
//     await _storage.delete(key: 'userData');
//     // await _storage.delete(key: 'cachedProfilePhoto');
//     notifyListeners();
//   }
// }

// class AppSettings extends ChangeNotifier {
//   String _theme = 'Light';
//   String _calendarView = 'Week';
//   String _fontSize = 'Medium';

//   String get theme => _theme;
//   String get calendarView => _calendarView;
//   String get fontSize => _fontSize;

//   bool get isDarkMode => _theme == 'Dark';

//   double get fontSizeValue {
//     switch (_fontSize) {
//       case 'Small':
//         return 12;
//       case 'Medium':
//         return 14;
//       case 'Large':
//         return 16;
//       case 'Extra Large':
//         return 18;
//       default:
//         return 14;
//     }
//   }

//   Future<void> loadPreferences() async {
//     final prefs = await SharedPreferences.getInstance();
//     _theme = prefs.getString('theme') ?? 'Light';
//     _fontSize = prefs.getString('fontSize') ?? 'Medium';
//     notifyListeners();
//   }

//   Future<void> setTheme(String theme) async {
//     _theme = theme;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('theme', theme);
//     notifyListeners();
//   }

//   Future<void> setFontSize(String size) async {
//     _fontSize = size;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('fontSize', size);
//     notifyListeners();
//   }
// }
