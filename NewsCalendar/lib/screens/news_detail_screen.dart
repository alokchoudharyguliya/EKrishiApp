import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/bookmark_service.dart';

class NewsDetailScreen extends StatefulWidget {
  final String newsId;
  final String imageUrl;
  final String title;
  final String description;
  final String? videoUrl;
  final List<String>? sources;

  const NewsDetailScreen({
    Key? key,
    required this.newsId,
    required this.imageUrl,
    required this.title,
    required this.description,
    this.videoUrl,
    this.sources,
  }) : super(key: key);

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  VideoPlayerController? _controller;
  bool _bookmarked = false;
  final BookmarkService _bookmarkService = BookmarkService();

  @override
  void initState() {
    super.initState();
    _loadBookmarkStatus();
    if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      _controller = VideoPlayerController.network(widget.videoUrl!)
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  Future<void> _loadBookmarkStatus() async {
    final isBookmarked = await _bookmarkService.isBookmarked(widget.newsId);
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
      await _bookmarkService.saveBookmark(widget.newsId, {
        'id': widget.newsId,
        'imageUrl': widget.imageUrl,
        'title': widget.title,
        'description': widget.description,
        'fullContent': widget.description,
        'sources': widget.sources ?? [],
      });
    } else {
      await _bookmarkService.removeBookmark(widget.newsId);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $url')),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: Icon(
              _bookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: _bookmarked ? Colors.orange : Colors.white,
            ),
            tooltip: _bookmarked ? 'Remove Bookmark' : 'Bookmark',
            onPressed: _toggleBookmark,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // News image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: Image.network(
                widget.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 40, color: Colors.grey),
                ),
              ),
            ),
            // Video section
            if (_controller != null && _controller!.value.isInitialized)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      VideoPlayer(_controller!),
                      VideoProgressIndicator(_controller!, allowScrubbing: true),
                      Center(
                        child: IconButton(
                          icon: Icon(
                            _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 48,
                          ),
                          onPressed: () {
                            setState(() {
                              _controller!.value.isPlaying
                                  ? _controller!.pause()
                                  : _controller!.play();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (widget.sources != null && widget.sources!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sources:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    ...widget.sources!.map((src) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: InkWell(
                            onTap: () => _launchUrl(src),
                            child: Row(
                              children: [
                                const Icon(Icons.link, size: 16, color: Colors.blue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    src,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}