import 'package:flutter/material.dart';

class NewsCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String description;

  const NewsCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  bool _expanded = false;
  static const int _maxChars = 80;

  @override
  Widget build(BuildContext context) {
    // Determine if text needs truncation
    final bool needsTruncation = widget.description.length > _maxChars;
    final String displayText =
        (!_expanded && needsTruncation)
            ? widget.description.substring(0, _maxChars) + '...'
            : widget.description;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: _expanded ? MediaQuery.of(context).size.width * 0.95 : null,
        constraints: BoxConstraints(
          minHeight: 120,
          maxWidth:
              _expanded
                  ? MediaQuery.of(context).size.width * 0.95
                  : double.infinity,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: Image.network(
                widget.imageUrl,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      width: 120,
                      height: 120,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
              ),
            ),
            // Text section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
            ),
          ],
        ),
      ),
    );
  }
}
