import 'package:flutter/material.dart';
import '../widgets/news.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);
  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  @override
  void initState() {}
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 16),
      children: [
        NewsCard(
          imageUrl:
              'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
          title: 'New Crop Varieties Released',
          description:
              'Scientists have developed new drought-resistant crop varieties to help farmers.',
        ),
        NewsCard(
          imageUrl:
              'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=400&q=80',
          title: 'Weather Alert for Farmers',
          description:
              'Heavy rains expected this week. Take precautions to protect your crops.',
        ),
        NewsCard(
          imageUrl:
              'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=400&q=80',
          title: 'Organic Farming Trends',
          description:
              'Organic farming is gaining popularity among young farmers.LOrganic farming is gaining popularity among young farmers.LOrganic farming is gaining popularity among young farmers.LOrganic farming is gaining popularity among young farmers.L',
        ),
        // Add more NewsCard widgets as needed
      ],
    );
  }
}
