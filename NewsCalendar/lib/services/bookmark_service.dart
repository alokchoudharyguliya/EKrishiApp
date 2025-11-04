import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BookmarkService {
  static const String _bookmarksKey = 'news_bookmarks';

  /// Save a bookmark for a news item
  Future<void> saveBookmark(String newsId, Map<String, dynamic> newsData) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = await getBookmarks();
    bookmarks[newsId] = newsData;
    await prefs.setString(_bookmarksKey, json.encode(bookmarks));
  }

  /// Remove a bookmark for a news item
  Future<void> removeBookmark(String newsId) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = await getBookmarks();
    bookmarks.remove(newsId);
    await prefs.setString(_bookmarksKey, json.encode(bookmarks));
  }

  /// Check if a news item is bookmarked
  Future<bool> isBookmarked(String newsId) async {
    final bookmarks = await getBookmarks();
    return bookmarks.containsKey(newsId);
  }

  /// Get all bookmarks
  Future<Map<String, dynamic>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarksString = prefs.getString(_bookmarksKey);
    if (bookmarksString != null) {
      try {
        final decoded = json.decode(bookmarksString) as Map<String, dynamic>;
        return decoded;
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  /// Get a specific bookmark
  Future<Map<String, dynamic>?> getBookmark(String newsId) async {
    final bookmarks = await getBookmarks();
    return bookmarks[newsId];
  }

  /// Clear all bookmarks
  Future<void> clearAllBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bookmarksKey);
  }
}

