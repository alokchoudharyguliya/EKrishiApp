import 'package:flutter/material.dart';
import '../screens/news_detail_screen.dart';
import '../services/bookmark_service.dart';

class NewsCard extends StatefulWidget {
  final String id;
  final String imageUrl;
  final String title;
  final String description;
  final String fullContent;
  final List<String>? sources;

  const NewsCard({
    Key? key,
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.description,
    this.fullContent = '',
    this.sources,
  }) : super(key: key);

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  bool _expanded = false;
  bool _bookmarked = false;
  final BookmarkService _bookmarkService = BookmarkService();
  static const int _maxChars = 80;

  @override
  void initState() {
    super.initState();
    _loadBookmarkStatus();
  }

  Future<void> _loadBookmarkStatus() async {
    final isBookmarked = await _bookmarkService.isBookmarked(widget.id);
    if (mounted) {
      setState(() {
        _bookmarked = isBookmarked;
      });
    }
  }

  Future<void> _toggleBookmark() async {
    setState(() {
      _bookmarked = !_bookmarked;
    });

    if (_bookmarked) {
      await _bookmarkService.saveBookmark(widget.id, {
        'id': widget.id,
        'imageUrl': widget.imageUrl,
        'title': widget.title,
        'description': widget.description,
        'fullContent': widget.fullContent.isNotEmpty ? widget.fullContent : widget.description,
        'sources': widget.sources ?? [],
      });
    } else {
      await _bookmarkService.removeBookmark(widget.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool needsTruncation = widget.description.length > _maxChars;
    final String displayText =
        (!_expanded && needsTruncation)
            ? widget.description.substring(0, _maxChars) + '...'
            : widget.description;

    return GestureDetector(
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          constraints: BoxConstraints(
            minHeight: 120,
            maxWidth: MediaQuery.of(context).size.width * 0.95,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Horizontal image at the top
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  widget.imageUrl,
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        width: double.infinity,
                        height: 160,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _bookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: _bookmarked ? Colors.orange : Colors.grey,
                          ),
                          tooltip: _bookmarked ? 'Remove Bookmark' : 'Bookmark',
                          onPressed: _toggleBookmark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      displayText,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: _expanded ? null : 3,
                      overflow:
                          _expanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                    ),
                    if (needsTruncation)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            setState(() {
                              _expanded = !_expanded;
                            });
                          },
                          child: Text(_expanded ? 'Read less' : 'Read more'),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => NewsDetailScreen(
                  newsId: widget.id,
                  imageUrl: widget.imageUrl,
                  title: widget.title,
                  description: widget.fullContent.isNotEmpty ? widget.fullContent : widget.description,
                  sources: widget.sources,
                ),
          ),
        );
      },
    );
  }
}
