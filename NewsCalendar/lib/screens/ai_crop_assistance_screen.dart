import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:newscalendar/services/auth_service.dart';
import 'package:newscalendar/constants/constants.dart';
import 'package:http_parser/http_parser.dart';
import 'package:newscalendar/services/gemini_api_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AICropAssistantScreen extends StatefulWidget {
  const AICropAssistantScreen({Key? key}) : super(key: key);

  @override
  State<AICropAssistantScreen> createState() => _AICropAssistantScreenState();
}

class _AICropAssistantScreenState extends State<AICropAssistantScreen> {
  int _step = 0;
  String? _selectedType;
  File? _imageFile;
  final _cropController = TextEditingController();
  final _problemController = TextEditingController();
  final _ageController = TextEditingController();
  bool? _recentWeather;
  bool _loading = false;
  String? _aiResult;

  final List<String> _types = ['Leaf', 'Stem', 'Soil', 'Whole Plant'];
  final List<String> _crops = ['Wheat', 'Rice', 'Sugarcane', 'Maize', 'Other'];

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  void _nextStep() {
    setState(() {
      _step++;
    });
  }

  void _prevStep() {
    setState(() {
      if (_step > 0) _step--;
    });
  }

  /// Format analysis result for display
  String _formatAnalysisResult(Map<String, dynamic> analysis) {
    final resultText = StringBuffer();
    resultText.writeln(
      '**Diagnosis:** ${analysis['diagnosis'] ?? 'No diagnosis available'}\n',
    );

    if (analysis['disease'] != null && analysis['disease'] != 'Unknown') {
      resultText.writeln('**Disease Identified:** ${analysis['disease']}');
    }

    if (analysis['confidence'] != null) {
      final confidencePercent = (analysis['confidence'] * 100).toStringAsFixed(
        0,
      );
      resultText.writeln('**Confidence:** $confidencePercent%');
    }

    if (analysis['severity'] != null) {
      resultText.writeln(
        '**Severity:** ${analysis['severity'].toString().toUpperCase()}\n',
      );
    }

    if (analysis['suggestions'] != null &&
        (analysis['suggestions'] as List).isNotEmpty) {
      resultText.writeln('**Suggestions:**');
      for (var suggestion in analysis['suggestions']) {
        resultText.writeln('• $suggestion');
      }
      resultText.writeln('');
    }

    if (analysis['treatment'] != null &&
        (analysis['treatment'] as List).isNotEmpty) {
      resultText.writeln('**Treatment:**');
      for (var treatment in analysis['treatment']) {
        if (treatment is Map) {
          resultText.writeln(
            '• **${treatment['product'] ?? 'Treatment'}**: ${treatment['application'] ?? ''}',
          );
          if (treatment['duration'] != null) {
            resultText.writeln('  Duration: ${treatment['duration']}');
          }
        }
      }
      resultText.writeln('');
    }

    if (analysis['prevention'] != null &&
        (analysis['prevention'] as List).isNotEmpty) {
      resultText.writeln('**Prevention Tips:**');
      for (var prevention in analysis['prevention']) {
        resultText.writeln('• $prevention');
      }
      resultText.writeln('');
    }

    if (analysis['references'] != null &&
        (analysis['references'] as List).isNotEmpty) {
      resultText.writeln('**References:**');
      for (var ref in analysis['references']) {
        resultText.writeln('• $ref');
      }
    }

    return resultText.toString();
  }

  /// Try direct Gemini API call
  Future<Map<String, dynamic>?> _tryDirectGeminiAPI() async {
    // Check if API key is configured
    if (GEMINI_API_KEY == 'YOUR_GEMINI_API_KEY_HERE' ||
        GEMINI_API_KEY.isEmpty) {
      print(
        '[AICropAssistant] Gemini API key not configured, skipping direct API',
      );
      return null;
    }

    try {
      print('[AICropAssistant] Attempting direct Gemini API call...');

      // Prepare context
      final context = {
        'imageType': _selectedType ?? 'Whole Plant',
        'cropType': _cropController.text,
        'observedProblem': _problemController.text,
        'plantAge': _ageController.text,
        'recentWeatherEvent': _recentWeather.toString(),
      };

      // Call direct Gemini API
      final result = await GeminiApiService.analyzeCropImage(
        apiKey: GEMINI_API_KEY,
        imageFile: _imageFile!,
        context: context,
        model: GEMINI_MODEL,
      );

      if (result['success'] == true) {
        print('[AICropAssistant] Direct Gemini API call successful');
        return result;
      } else {
        print(
          '[AICropAssistant] Direct Gemini API call failed: ${result['error']}',
        );
        return null;
      }
    } catch (e) {
      print('[AICropAssistant] Exception in direct Gemini API: $e');
      return null;
    }
  }

  /// Fallback to backend API
  Future<Map<String, dynamic>> _callBackendAPI() async {
    // Get auth token
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = await authService.getAuthToken();

    if (token == null) {
      throw Exception('Please login to continue');
    }

    // Prepare form data
    final formData = FormData.fromMap({
      'imageType': _selectedType ?? 'Whole Plant',
      'cropType': _cropController.text,
      'problem': _problemController.text,
      'plantAge': _ageController.text,
      'recentWeather': _recentWeather.toString(),
    });

    // Add image file
    final imageMediaType = _getImageMediaType(_imageFile!.path);
    final fileExtension = _imageFile!.path.split('.').last;
    final filename =
        'crop_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

    final multipartFile = await MultipartFile.fromFile(
      _imageFile!.path,
      filename: filename,
      contentType: imageMediaType,
    );
    formData.files.add(MapEntry('image', multipartFile));

    // Make API request
    final dio = Dio();
    print(
      '[AICropAssistant] Falling back to backend API: $BASE_URL/api/ai/crop-analysis-gemini',
    );

    final response = await dio
        .post(
          '$BASE_URL/api/ai/crop-analysis-gemini',
          data: formData,
          options: Options(
            contentType: 'multipart/form-data',
            headers: {'Authorization': 'Bearer $token'},
          ),
        )
        .timeout(const Duration(seconds: 60));

    print(
      '[AICropAssistant] Backend response received: ${response.statusCode}',
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data;
    } else {
      throw Exception(response.data['message'] ?? 'Analysis failed');
    }
  }

  Future<void> _analyze() async {
    print('[AICropAssistant] _analyze() called');
    print('[AICropAssistant] Step: $_step');
    print('[AICropAssistant] Image file: ${_imageFile != null}');
    print('[AICropAssistant] Crop type: ${_cropController.text}');
    print('[AICropAssistant] Problem: ${_problemController.text}');
    print('[AICropAssistant] Plant age: ${_ageController.text}');
    print('[AICropAssistant] Weather: $_recentWeather');

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an image first')),
      );
      return;
    }

    // Move to step 3 immediately to show loading state
    setState(() {
      _step = 3;
      _loading = true;
      _aiResult = null;
    });

    try {
      Map<String, dynamic>? analysis;
      bool usedDirectAPI = false;

      // Try direct Gemini API first
      final directResult = await _tryDirectGeminiAPI();
      if (directResult != null && directResult['success'] == true) {
        analysis = directResult['analysis'];
        usedDirectAPI = true;
        print('[AICropAssistant] Using direct Gemini API result');
      } else {
        // Fallback to backend API
        print(
          '[AICropAssistant] Direct API failed or unavailable, using backend fallback',
        );
        final backendResponse = await _callBackendAPI();
        if (backendResponse['success'] == true) {
          analysis = backendResponse['analysis'];
          print('[AICropAssistant] Using backend API result');
        } else {
          throw Exception(backendResponse['message'] ?? 'Analysis failed');
        }
      }

      // Format and display result
      if (analysis != null) {
        print(
          '[AICropAssistant] Analysis successful (${usedDirectAPI ? 'Direct API' : 'Backend API'})',
        );
        print('[AICropAssistant] Diagnosis: ${analysis['diagnosis']}');
        print('[AICropAssistant] Disease: ${analysis['disease']}');
        print('[AICropAssistant] Confidence: ${analysis['confidence']}');

        final resultText = _formatAnalysisResult(analysis);

        setState(() {
          _loading = false;
          _aiResult = resultText.toString();
        });
        print('[AICropAssistant] Result formatted and displayed');
      } else {
        throw Exception('Failed to get analysis result');
      }
    } catch (e) {
      print('[AICropAssistant] Error occurred: $e');
      setState(() {
        _loading = false;
      });

      if (mounted) {
        String errorMessage = 'Analysis failed. Please try again.';

        // Parse error for user-friendly messages
        final errorString = e.toString();
        if (errorString.contains('TimeoutException') ||
            errorString.contains('timeout')) {
          errorMessage =
              'Request timed out. Please check your connection and try again.';
        } else if (errorString.contains('SocketException') ||
            errorString.contains('network')) {
          errorMessage =
              'Network error. Please check your internet connection.';
        } else if (errorString.contains('401') ||
            errorString.contains('Unauthorized')) {
          errorMessage = 'Authentication failed. Please login again.';
        } else if (errorString.contains('400') ||
            errorString.contains('Bad Request')) {
          errorMessage =
              'Invalid request. Please check your input and try again.';
        } else if (errorString.contains('500') ||
            errorString.contains('Internal Server Error')) {
          errorMessage = 'Server error. Please try again later.';
        } else if (errorString.isNotEmpty) {
          // Extract meaningful error message
          final match = RegExp(r'Error: (.+)').firstMatch(errorString);
          if (match != null) {
            errorMessage = match.group(1) ?? errorMessage;
          } else {
            // Remove common prefixes
            errorMessage = errorString
                .replaceAll('Exception: ', '')
                .replaceAll('DioException: ', '');
            if (errorMessage.length > 100) {
              errorMessage = errorMessage.substring(0, 100) + '...';
            }
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                _analyze();
              },
            ),
          ),
        );
      }
    }
  }

  /// Get MIME type for image file
  MediaType _getImageMediaType(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('image', 'jpeg');
    }
  }

  @override
  void dispose() {
    _cropController.dispose();
    _problemController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Crop Assistant'),
        backgroundColor: Colors.green[700],
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _step,
        onStepContinue: () async {
          if (_step == 0 && _selectedType != null) {
            _nextStep();
          } else if (_step == 1 && _imageFile != null) {
            _nextStep();
          } else if (_step == 2 &&
              _cropController.text.isNotEmpty &&
              _problemController.text.isNotEmpty &&
              _ageController.text.isNotEmpty &&
              _recentWeather != null) {
            await _analyze();
          } else if (_step == 3) {
            Navigator.pop(context);
          }
        },
        onStepCancel: _prevStep,
        controlsBuilder: (context, details) {
          return Row(
            children: [
              if (_step < 3)
                ElevatedButton(
                  onPressed: _loading ? null : details.onStepContinue,
                  child: Text(_step == 2 ? 'Analyze' : 'Next'),
                ),
              if (_step > 0 && _step < 3 && !_loading)
                TextButton(
                  onPressed: details.onStepCancel,
                  child: const Text('Back'),
                ),
              if (_step == 3 && !_loading)
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
            ],
          );
        },
        steps: [
          Step(
            title: const Text('Select Image Type'),
            isActive: _step >= 0,
            content: Wrap(
              spacing: 12,
              children:
                  _types.map((type) {
                    return ChoiceChip(
                      label: Text(type),
                      selected: _selectedType == type,
                      onSelected: (selected) {
                        setState(() {
                          _selectedType = type;
                        });
                      },
                    );
                  }).toList(),
            ),
          ),
          Step(
            title: const Text('Upload Image'),
            isActive: _step >= 1,
            content: Column(
              children: [
                if (_imageFile != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Image.file(_imageFile!, height: 160),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Answer Questions'),
            isActive: _step >= 2,
            content: Column(
              children: [
                DropdownButtonFormField<String>(
                  value:
                      _cropController.text.isNotEmpty
                          ? _cropController.text
                          : null,
                  decoration: const InputDecoration(labelText: 'Crop Type'),
                  items:
                      _crops
                          .map(
                            (crop) => DropdownMenuItem(
                              value: crop,
                              child: Text(crop),
                            ),
                          )
                          .toList(),
                  onChanged:
                      (val) => setState(() => _cropController.text = val ?? ''),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _problemController,
                  decoration: const InputDecoration(
                    labelText: 'Observed Problem',
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(
                    labelText: 'Plant Age (days)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Recent Weather Event?'),
                    const SizedBox(width: 10),
                    ChoiceChip(
                      label: const Text('Yes'),
                      selected: _recentWeather == true,
                      onSelected:
                          (selected) => setState(() => _recentWeather = true),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('No'),
                      selected: _recentWeather == false,
                      onSelected:
                          (selected) => setState(() => _recentWeather = false),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Step(
            title: const Text('AI Diagnosis'),
            isActive: _step >= 3,
            content:
                _loading
                    ? Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(
                              'Analyzing crop image...',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'This may take a few moments',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    : _aiResult != null
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Result Card with scrollable content
                        Card(
                          elevation: 2,
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 400),
                            padding: const EdgeInsets.all(16.0),
                            child: SingleChildScrollView(
                              child: MarkdownBody(
                                data: _aiResult!,
                                selectable: true,
                                styleSheet: MarkdownStyleSheet(
                                  p: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 15,
                                    height: 1.5,
                                  ),
                                  strong: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  em: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.black87,
                                  ),
                                  listBullet: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 15,
                                  ),
                                  listIndent: 24.0,
                                  h1: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  h2: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  h3: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  code: TextStyle(
                                    backgroundColor: Colors.grey[300],
                                    color: Colors.black87,
                                    fontFamily: 'monospace',
                                  ),
                                  codeblockDecoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  blockquote: const TextStyle(
                                    color: Colors.black54,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  blockquoteDecoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(
                                        color: Colors.grey[400]!,
                                        width: 4,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.refresh),
                                label: const Text('Analyze Again'),
                                onPressed: () {
                                  setState(() {
                                    _step = 0;
                                    _selectedType = null;
                                    _imageFile = null;
                                    _cropController.clear();
                                    _problemController.clear();
                                    _ageController.clear();
                                    _recentWeather = null;
                                    _aiResult = null;
                                    _loading = false;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.medical_information),
                                label: const Text('Contact Expert'),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/doctor-contact',
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[700],
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ////////////////////////
// ///
// ///import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:cached_network_image/cached_network_image.dart';

// class AICropAssistantScreen extends StatefulWidget {
//   const AICropAssistantScreen({Key? key}) : super(key: key);

//   @override
//   State<AICropAssistantScreen> createState() => _AICropAssistantScreenState();
// }

// class _AICropAssistantScreenState extends State<AICropAssistantScreen> {
//   int _step = 0;
//   String? _selectedType;
//   File? _imageFile;
//   final _cropController = TextEditingController();
//   final _problemController = TextEditingController();
//   final _ageController = TextEditingController();
//   bool? _recentWeather;
//   bool _loading = false;
//   String? _aiResult;

//   final List<String> _types = ['Leaf', 'Stem', 'Soil', 'Whole Plant'];
//   final List<String> _crops = ['Wheat', 'Rice', 'Sugarcane', 'Maize', 'Other'];

//   // Placeholder image URLs for each image type
//   String? _getPlaceholderImageUrl() {
//     if (_selectedType == null) return null;
//     switch (_selectedType) {
//       case 'Leaf':
//         return 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400&h=300&fit=crop';
//       case 'Stem':
//         return 'https://images.unsplash.com/photo-1466692476868-aef1dfb1e735?w=400&h=300&fit=crop';
//       case 'Soil':
//         return 'https://images.unsplash.com/photo-1593297813757-4c8e3b88e67e?w=400&h=300&fit=crop';
//       case 'Whole Plant':
//         return 'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=400&h=300&fit=crop';
//       default:
//         return 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400&h=300&fit=crop';
//     }
//   }

//   // Placeholder result image asset path
//   static const String _resultPlaceholderImageUrl =
//       'assets/images/potato-early-blight-leaves.jpg';

//   // Sample diagnosis result
//   static const String _sampleDiagnosisResult =
//       "Possible diagnosis: Early blight detected.\n\n"
//       "Confidence: 72%\n"
//       "Severity: Moderate\n\n"
//       "Symptoms identified:\n"
//       "• Dark brown circular lesions on leaves\n"
//       "• Yellowing around affected areas\n"
//       "• Premature leaf drop\n\n"
//       "Suggestions:\n"
//       "- Remove affected leaves immediately\n"
//       "- Apply recommended fungicide (Copper-based)\n"
//       "- Ensure proper drainage to prevent waterlogging\n"
//       "- Maintain adequate spacing between plants\n"
//       "- Apply treatment early morning or late evening\n\n"
//       "References:\n"
//       "• https://agri-research.org/early-blight\n"
//       "• https://youtube.com/watch?v=example";

//   Future<void> _pickImage(ImageSource source) async {
//     final picker = ImagePicker();
//     final picked = await picker.pickImage(
//       source: source,
//       imageQuality: 85,
//       maxWidth: 800,
//       maxHeight: 800,
//     );
//     if (picked != null) {
//       setState(() {
//         _imageFile = File(picked.path);
//       });
//     }
//   }

//   void _nextStep() {
//     setState(() {
//       _step++;
//       // Pre-fill form fields with sample data when reaching step 2
//       if (_step == 2) {
//         if (_cropController.text.isEmpty) {
//           _cropController.text = 'Wheat';
//         }
//         if (_problemController.text.isEmpty) {
//           _problemController.text = 'Brown spots appearing on leaves';
//         }
//         if (_ageController.text.isEmpty) {
//           _ageController.text = '45';
//         }
//         if (_recentWeather == null) {
//           _recentWeather = false;
//         }
//       }
//     });
//   }

//   void _prevStep() {
//     setState(() {
//       if (_step > 0) _step--;
//     });
//   }

//   Future<void> _analyze() async {
//     setState(() {
//       _loading = true;
//     });
//     // Simulate AI analysis delay
//     await Future.delayed(const Duration(seconds: 2));
//     setState(() {
//       _loading = false;
//       _aiResult = _sampleDiagnosisResult;
//       _step++;
//     });
//   }

//   @override
//   void dispose() {
//     _cropController.dispose();
//     _problemController.dispose();
//     _ageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('AI Crop Assistant'),
//         backgroundColor: Colors.green[700],
//       ),
//       body: Stepper(
//         type: StepperType.vertical,
//         currentStep: _step,
//         onStepContinue: () async {
//           if (_step == 0 && _selectedType != null) {
//             _nextStep();
//           } else if (_step == 1 && _selectedType != null) {
//             // Allow proceeding with placeholder image or uploaded image
//             _nextStep();
//           } else if (_step == 2 &&
//               _cropController.text.isNotEmpty &&
//               _problemController.text.isNotEmpty &&
//               _ageController.text.isNotEmpty &&
//               _recentWeather != null) {
//             await _analyze();
//           } else if (_step == 3) {
//             Navigator.pop(context);
//           }
//         },
//         onStepCancel: _prevStep,
//         controlsBuilder: (context, details) {
//           return Row(
//             children: [
//               if (_step < 3)
//                 ElevatedButton(
//                   onPressed: details.onStepContinue,
//                   child: Text(_step == 2 ? 'Analyze' : 'Next'),
//                 ),
//               if (_step > 0 && _step < 3)
//                 TextButton(
//                   onPressed: details.onStepCancel,
//                   child: const Text('Back'),
//                 ),
//               if (_step == 3)
//                 ElevatedButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('Done'),
//                 ),
//             ],
//           );
//         },
//         steps: [
//           Step(
//             title: const Text('Select Image Type'),
//             isActive: _step >= 0,
//             content: Wrap(
//               spacing: 12,
//               children:
//                   _types.map((type) {
//                     return ChoiceChip(
//                       label: Text(type),
//                       selected: _selectedType == type,
//                       onSelected: (selected) {
//                         setState(() {
//                           _selectedType = type;
//                         });
//                       },
//                     );
//                   }).toList(),
//             ),
//           ),
//           Step(
//             title: const Text('Upload Image'),
//             isActive: _step >= 1,
//             content: Column(
//               children: [
//                 // Show placeholder or uploaded image
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 12.0),
//                   child:
//                       _imageFile != null
//                           ? Image.file(
//                             _imageFile!,
//                             height: 200,
//                             fit: BoxFit.cover,
//                           )
//                           : _selectedType != null
//                           ? ClipRRect(
//                             borderRadius: BorderRadius.circular(8),
//                             child: CachedNetworkImage(
//                               imageUrl: _getPlaceholderImageUrl()!,
//                               height: 200,
//                               width: double.infinity,
//                               fit: BoxFit.cover,
//                               placeholder:
//                                   (context, url) => Container(
//                                     height: 200,
//                                     color: Colors.grey[300],
//                                     child: const Center(
//                                       child: CircularProgressIndicator(),
//                                     ),
//                                   ),
//                               errorWidget:
//                                   (context, url, error) => Container(
//                                     height: 200,
//                                     color: Colors.grey[300],
//                                     child: const Icon(
//                                       Icons.image_not_supported,
//                                     ),
//                                   ),
//                             ),
//                           )
//                           : Container(
//                             height: 200,
//                             color: Colors.grey[200],
//                             child: const Center(
//                               child: Text(
//                                 'Please select an image type first',
//                                 style: TextStyle(color: Colors.grey),
//                               ),
//                             ),
//                           ),
//                 ),
//                 if (_imageFile == null && _selectedType != null)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 12.0),
//                     child: Text(
//                       'Showing placeholder image for $_selectedType',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey[600],
//                         fontStyle: FontStyle.italic,
//                       ),
//                     ),
//                   ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     ElevatedButton.icon(
//                       icon: const Icon(Icons.camera_alt),
//                       label: const Text('Camera'),
//                       onPressed: () => _pickImage(ImageSource.camera),
//                     ),
//                     const SizedBox(width: 16),
//                     ElevatedButton.icon(
//                       icon: const Icon(Icons.photo_library),
//                       label: const Text('Gallery'),
//                       onPressed: () => _pickImage(ImageSource.gallery),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Step(
//             title: const Text('Answer Questions'),
//             isActive: _step >= 2,
//             content: Column(
//               children: [
//                 DropdownButtonFormField<String>(
//                   value:
//                       _cropController.text.isNotEmpty
//                           ? _cropController.text
//                           : null,
//                   decoration: const InputDecoration(labelText: 'Crop Type'),
//                   items:
//                       _crops
//                           .map(
//                             (crop) => DropdownMenuItem(
//                               value: crop,
//                               child: Text(crop),
//                             ),
//                           )
//                           .toList(),
//                   onChanged:
//                       (val) => setState(() => _cropController.text = val ?? ''),
//                 ),
//                 const SizedBox(height: 10),
//                 TextFormField(
//                   controller: _problemController,
//                   decoration: const InputDecoration(
//                     labelText: 'Observed Problem',
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 TextFormField(
//                   controller: _ageController,
//                   decoration: const InputDecoration(
//                     labelText: 'Plant Age (days)',
//                   ),
//                   keyboardType: TextInputType.number,
//                 ),
//                 const SizedBox(height: 10),
//                 Row(
//                   children: [
//                     const Text('Recent Weather Event?'),
//                     const SizedBox(width: 10),
//                     ChoiceChip(
//                       label: const Text('Yes'),
//                       selected: _recentWeather == true,
//                       onSelected:
//                           (selected) => setState(() => _recentWeather = true),
//                     ),
//                     const SizedBox(width: 8),
//                     ChoiceChip(
//                       label: const Text('No'),
//                       selected: _recentWeather == false,
//                       onSelected:
//                           (selected) => setState(() => _recentWeather = false),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Step(
//             title: const Text('AI Diagnosis'),
//             isActive: _step >= 3,
//             content:
//                 _loading
//                     ? const Padding(
//                       padding: EdgeInsets.all(24.0),
//                       child: Center(child: CircularProgressIndicator()),
//                     )
//                     : _aiResult != null
//                     ? Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Placeholder result image
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(8),
//                           child: Image.asset(
//                             _resultPlaceholderImageUrl,
//                             height: 200,
//                             width: double.infinity,
//                             fit: BoxFit.cover,
//                             errorBuilder:
//                                 (context, error, stackTrace) => Container(
//                                   height: 200,
//                                   color: Colors.grey[300],
//                                   child: const Icon(Icons.image_not_supported),
//                                 ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         Text(_aiResult!, style: const TextStyle(fontSize: 16)),
//                         const SizedBox(height: 16),
//                         ElevatedButton.icon(
//                           icon: const Icon(Icons.medical_information),
//                           label: const Text('Contact Expert'),
//                           onPressed: () {
//                             Navigator.pushNamed(context, '/doctor-contact');
//                           },
//                         ),
//                       ],
//                     )
//                     : const SizedBox.shrink(),
//           ),
//         ],
//       ),
//     );
//   }
// }
