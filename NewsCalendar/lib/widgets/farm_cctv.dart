/// Farm CCTV Widget - Animal Detection Camera Streams
///
/// Uses WebView to display Flask server's camera feed
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FarmCCTV extends StatefulWidget {
  const FarmCCTV({Key? key}) : super(key: key);

  @override
  State<FarmCCTV> createState() => _FarmCCTVState();
}

class _FarmCCTVState extends State<FarmCCTV> with TickerProviderStateMixin {
  // Flask server configuration
  static const String _flaskServerUrl = 'http://192.168.29.145:8000';

  late WebViewController _webViewController;
  bool _isLoading = true;
  String? _errorMessage;

  // Animation controllers
  late AnimationController _statusBadgeController;
  late AnimationController _refreshController;
  late Animation<double> _statusPulseAnimation;
  late Animation<double> _refreshRotationAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _statusBadgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _statusPulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _statusBadgeController, curve: Curves.easeInOut),
    );

    _refreshRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _refreshController, curve: Curves.easeInOut),
    );

    _initializeWebView();
  }

  @override
  void dispose() {
    _statusBadgeController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _initializeWebView() {
    _webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
              },
              onPageFinished: (String url) {
                setState(() {
                  _isLoading = false;
                });
              },
              onWebResourceError: (WebResourceError error) {
                setState(() {
                  _isLoading = false;
                  _errorMessage = 'Failed to load page: ${error.description}';
                });
                debugPrint('[FarmCCTV] WebView error: ${error.description}');
              },
            ),
          )
          ..loadRequest(Uri.parse(_flaskServerUrl));
  }

  void _refreshStream() {
    // Animate refresh button
    _refreshController.forward().then((_) {
      _refreshController.reset();
    });

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });
    _webViewController.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Farm CCTV', style: Theme.of(context).textTheme.headlineSmall),
            // Animated refresh button
            RotationTransition(
              turns: _refreshRotationAnimation,
              child: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refreshStream,
                tooltip: 'Refresh stream',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // WebView display section
        Expanded(
          child: Container(
            height: 300,
            width: 300,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    _errorMessage == null && !_isLoading
                        ? Colors.green
                        : _errorMessage != null
                        ? Colors.red
                        : Colors.grey,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  // WebView
                  WebViewWidget(controller: _webViewController),

                  // Loading indicator with animation
                  if (_isLoading)
                    Container(
                      color: Colors.black87,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const CircularProgressIndicator(
                                color: Colors.green,
                                strokeWidth: 3,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading camera stream...',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Animated connection status badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child:
                        _errorMessage == null && !_isLoading
                            ? ScaleTransition(
                              scale: _statusPulseAnimation,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.5),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.fiber_manual_record,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'LIVE',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            : Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    _errorMessage != null
                                        ? Colors.red
                                        : Colors.orange,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _errorMessage != null
                                        ? Icons.error_outline
                                        : Icons.hourglass_empty,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _errorMessage != null ? 'ERROR' : 'LOADING',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                  ),

                  // // Error message overlay
                  // if (_errorMessage != null)
                  //   Positioned(
                  //     bottom: 20,
                  //     left: 20,
                  //     right: 20,
                  //     child: Container(
                  //       padding: const EdgeInsets.all(12),
                  //       decoration: BoxDecoration(
                  //         color: Colors.red.withOpacity(0.9),
                  //         borderRadius: BorderRadius.circular(8),
                  //       ),
                  //       child: Row(
                  //         children: [
                  //           const Icon(
                  //             Icons.error_outline,
                  //             color: Colors.white,
                  //             size: 20,
                  //           ),
                  //           const SizedBox(width: 8),
                  //           Expanded(
                  //             child: Text(
                  //               'Connection Error: $_errorMessage',
                  //               style: const TextStyle(
                  //                 color: Colors.white,
                  //                 fontSize: 12,
                  //               ),
                  //               maxLines: 2,
                  //               overflow: TextOverflow.ellipsis,
                  //             ),
                  //           ),
                  //           IconButton(
                  //             icon: const Icon(
                  //               Icons.close,
                  //               color: Colors.white,
                  //               size: 20,
                  //             ),
                  //             onPressed: () {
                  //               setState(() {
                  //                 _errorMessage = null;
                  //               });
                  //             },
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}
