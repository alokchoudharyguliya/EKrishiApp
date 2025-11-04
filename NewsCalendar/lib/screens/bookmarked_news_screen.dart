import 'package:flutter/material.dart';
import '../widgets/news.dart';
import '../services/bookmark_service.dart';

class BookmarkedNewsScreen extends StatefulWidget {
  const BookmarkedNewsScreen({Key? key}) : super(key: key);

  @override
  State<BookmarkedNewsScreen> createState() => _BookmarkedNewsScreenState();
}

class _BookmarkedNewsScreenState extends State<BookmarkedNewsScreen> {
  final BookmarkService _bookmarkService = BookmarkService();
  Map<String, dynamic> _bookmarks = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    setState(() {
      _isLoading = true;
    });

    final bookmarks = await _bookmarkService.getBookmarks();
    
    if (mounted) {
      setState(() {
        _bookmarks = bookmarks;
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshBookmarks() async {
    await _loadBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarked News'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _refreshBookmarks,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _bookmarks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_border,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No bookmarked news yet',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bookmark news articles to view them here',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                            ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshBookmarks,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    children: _bookmarks.values.map((newsData) {
                      return NewsCard(
                        id: newsData['id'] ?? '',
                        imageUrl: newsData['imageUrl'] ?? '',
                        title: newsData['title'] ?? '',
                        description: newsData['description'] ?? '',
                        fullContent: newsData['fullContent'] ?? newsData['description'] ?? '',
                        sources: newsData['sources'] is List
                            ? List<String>.from(newsData['sources'])
                            : null,
                      );
                    }).toList(),
                  ),
                ),
    );
  }
}

