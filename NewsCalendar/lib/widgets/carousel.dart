import 'package:flutter/material.dart';
import '../utils/imports.dart';
import 'dart:async';

class SlidingCarousel extends StatefulWidget {
  @override
  _SlidingCarouselState createState() => _SlidingCarouselState();
}

class _SlidingCarouselState extends State<SlidingCarousel> {
  final List<Map<String, String>> items = [
    {'text': 'Box 1', 'image': 'assets/images/image1.jpg'},
    {'text': 'Box 2', 'image': 'assets/images/image2.jpg'},
    {'text': 'Box 3', 'image': 'assets/images/image3.jpg'},
    {'text': 'Box 4', 'image': 'assets/images/image4.jpg'},
    {'text': 'Box 5', 'image': 'assets/images/image5.jpg'},
    // Add more items if needed
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (_currentPage < items.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(seconds: 1),
          curve: Curves.linear,
        );
      }
    });
  }

  void _goToPage(int page) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        page,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: items.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Image with dark overlay
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(
                            0.4,
                          ), // Adjust opacity for darkness
                          BlendMode.darken,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Image.asset(
                            items[index]['image']!,
                            height: double.infinity,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // Text overlay
                    ),
                    Center(
                      child: Text(
                        items[index]['text']!,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.8),
                              blurRadius: 6,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        SizedBox(height: 6),
        // Indicator dots - now clickable
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(items.length, (index) {
            return GestureDetector(
              onTap: () {
                _goToPage(index);
              },
              child: Container(
                width: 12, // Slightly larger for better touch target
                height: 12,
                margin: EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      _currentPage == index
                          ? Colors
                              .blue // Active dot color
                          : Colors.grey.withOpacity(0.5), // Inactive dot color
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
