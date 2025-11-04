import 'package:flutter/material.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class SlidingCarousel extends StatefulWidget {
  @override
  _SlidingCarouselState createState() => _SlidingCarouselState();
}

class _SlidingCarouselState extends State<SlidingCarousel> {
  final List<Map<String, String>> items = [
    // {
    //   'text':
    //       'UP Government Free Boring Scheme - Apply Now for Free Borewell Installation',
    //   'image':
    //       'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?auto=format&fit=crop&w=1200&q=80',
    //   'url': 'https://up.gov.in/en/scheme/up-free-boring-scheme',
    // },
    // {
    //   'text':
    //       'PM Kisan Samman Nidhi - ₹6000 Direct Benefit Transfer to Farmers',
    //   'image':
    //       'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?auto=format&fit=crop&w=1200&q=80',
    //   'url': 'https://pmkisan.gov.in/',
    // },
    // {
    //   'text': 'Kisan Credit Card - Low Interest Loans for Agricultural Needs',
    //   'image':
    //       'https://images.unsplash.com/photo-1593113598332-cd288d649433?auto=format&fit=crop&w=1200&q=80',
    //   'url': 'https://www.india.gov.in/kisan-credit-card-kcc',
    // },
    {
      'text':
          'UP Government Free Boring Scheme - Apply Now for Free Borewell Installation',
      'image':
          'https://storage.googleapis.com/ekrishi__bucket/1707985575-up-free-boring-scheme-apply-complete-information%20(3).jpg',
      'url': 'https://up.gov.in/en/scheme/up-free-boring-scheme',
    },
    {
      'text':
          'PM Kisan Samman Nidhi - ₹6000 Direct Benefit Transfer to Farmers',
      'image':
          'https://storage.googleapis.com/ekrishi__bucket/Up-farmers-big-relief-english.jpg',
      'url': 'https://pmkisan.gov.in/',
    },
    {
      'text': 'Kisan Credit Card - Low Interest Loans for Agricultural Needs',
      'image':
          'https://images.unsplash.com/photo-1593113598332-cd288d649433?auto=format&fit=crop&w=1200&q=80',
      'url': 'https://www.india.gov.in/kisan-credit-card-kcc',
    },

    {
      'text': 'Pradhan Mantri Fasal Bima Yojana - Crop Insurance for Farmers',
      'image':
          'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80',
      'url': 'https://pmfby.gov.in/',
    },
    {
      'text':
          'Soil Health Card Scheme - Get Free Soil Testing and Recommendations',
      'image':
          'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?auto=format&fit=crop&w=1200&q=80',
      'url': 'https://soilhealth.dac.gov.in/',
    },
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
              return GestureDetector(
                onTap: () async {
                  final url = items[index]['url'];
                  if (url != null && url.isNotEmpty) {
                    try {
                      // Ensure URL has proper scheme
                      String finalUrl = url.trim();
                      if (!finalUrl.startsWith('http://') &&
                          !finalUrl.startsWith('https://')) {
                        finalUrl = 'https://$finalUrl';
                      }

                      final uri = Uri.parse(finalUrl);

                      // Launch URL - try externalApplication first, then platformDefault as fallback
                      try {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      } catch (e) {
                        // Fallback to platformDefault if externalApplication fails
                        try {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.platformDefault,
                          );
                        } catch (e2) {
                          // Show error message only if both methods fail
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Could not open link. Please check your internet connection.',
                                ),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: Invalid URL format'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  }
                },
                child: Container(
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
                            child:
                                items[index]['image']!.startsWith('http')
                                    ? Image.network(
                                      items[index]['image']!,
                                      height: double.infinity,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          color: Colors.grey[300],
                                          child: Icon(
                                            Icons.error,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                      loadingBuilder: (
                                        context,
                                        child,
                                        loadingProgress,
                                      ) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value:
                                                loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                          ),
                                        );
                                      },
                                    )
                                    : Image.asset(
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
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Text(
                            items[index]['text']!,
                            style: TextStyle(
                              fontSize: 12,
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
                      ),
                    ],
                  ),
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
