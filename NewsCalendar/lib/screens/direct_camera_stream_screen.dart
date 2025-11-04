/// Direct Camera Stream Screen
///
/// Renders the Flask web page with camera feed using WebView
/// Example: http://192.168.29.170:5000
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DirectCameraStreamScreen extends StatefulWidget {
  final String?
  serverUrl; // Base URL of the Flask server (e.g., http://192.168.29.170:5000)

  const DirectCameraStreamScreen({Key? key, this.serverUrl}) : super(key: key);

  @override
  State<DirectCameraStreamScreen> createState() =>
      _DirectCameraStreamScreenState();
}

class _DirectCameraStreamScreenState extends State<DirectCameraStreamScreen> {
  // Default server URL (can be customized)
  static const String _defaultServerUrl = 'http://192.168.29.145:8000/';

  late WebViewController _webViewController;
  String _serverUrl = _defaultServerUrl;
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Use provided server URL or default
    _serverUrl = widget.serverUrl ?? _defaultServerUrl;
    _urlController.text = _serverUrl;

    // Initialize WebView controller
    _initializeWebView();
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
                debugPrint(
                  '[DirectCameraStream] WebView error: ${error.description}',
                );
              },
            ),
          )
          ..loadRequest(Uri.parse(_serverUrl));
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _updateServerUrl() {
    final newUrl = _urlController.text.trim();
    if (newUrl.isNotEmpty && newUrl != _serverUrl) {
      // Ensure URL has protocol
      String urlWithProtocol = newUrl;
      if (!urlWithProtocol.startsWith('http://') &&
          !urlWithProtocol.startsWith('https://')) {
        urlWithProtocol = 'http://$newUrl';
      }

      setState(() {
        _serverUrl = urlWithProtocol;
        _errorMessage = null;
        _isLoading = true;
      });

      // Reload WebView with new URL
      _webViewController.loadRequest(Uri.parse(_serverUrl));
    }
  }

  void _refreshStream() {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });
    _webViewController.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Stream'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshStream,
            tooltip: 'Refresh stream',
          ),
        ],
      ),
      body: Column(
        children: [
          // URL input section
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Server URL',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _urlController,
                        decoration: InputDecoration(
                          hintText:
                              'Enter Flask server URL (e.g., http://192.168.29.170:5000)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _updateServerUrl,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Connect'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // WebView display section
          Expanded(
            child: Stack(
              children: [
                // WebView
                WebViewWidget(controller: _webViewController),

                // Loading indicator
                if (_isLoading)
                  Container(
                    color: Colors.black87,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white54),
                          SizedBox(height: 16),
                          Text(
                            'Loading camera stream...',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Connection status badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _errorMessage == null && !_isLoading
                              ? Colors.green
                              : _errorMessage != null
                              ? Colors.red
                              : Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _errorMessage == null && !_isLoading
                              ? Icons.fiber_manual_record
                              : _errorMessage != null
                              ? Icons.error_outline
                              : Icons.hourglass_empty,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _errorMessage == null && !_isLoading
                              ? 'LIVE'
                              : _errorMessage != null
                              ? 'ERROR'
                              : 'LOADING',
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

                // Error message overlay
                if (_errorMessage != null)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Connection Error: $_errorMessage',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _errorMessage = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
