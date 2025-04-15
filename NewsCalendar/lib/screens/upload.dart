import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import '../firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'edit_event_screen.dart';
import 'package:intl/intl.dart';

class ImageUploadScreen extends StatefulWidget {
  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  File? _image;
  String _extractedText = "";
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = false;
  String _vertexAIResponse = "";
  static const String _apiKey =
      'AIzaSyAZjj3WDWIPST9r4W0T5QNVv80SGH6jMSM'; // Replace with your actual API key

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isFirebaseInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      setState(() {
        _isFirebaseInitialized = true;
      });
    } catch (e) {
      print('Firebase initialization error: $e');
    }
  }

  Future<void> _saveToJsonFile(List<Map<String, dynamic>> events) async {
    //   try {
    //     final directory = await getApplicationDocumentsDirectory();
    //     final file = File('${directory.path}/events.json');
    //     await file.writeAsString(jsonEncode({'events': events}));
    //     print('Events saved to ${file.path}');
    //   } catch (e) {
    //     print('Error saving to JSON file: $e');
    //   }
  }

  Future<void> _saveToFirestore(List<Map<String, dynamic>> events) async {
    // if (!_isFirebaseInitialized) {
    //   print('Firebase not initialized');
    //   return;
    // }

    try {
      final collectionRef = _firestore.collection('events');
      final batch = _firestore.batch();

      for (var event in events) {
        final docRef = collectionRef.doc();
        batch.set(docRef, {
          'event': event['event'],
          'start_date': event['start_date'],
          'end_date': event['end_date'],
        });
      }

      await batch.commit();
      print('Events saved to Firestore');
    } catch (e) {
      print('Error saving to Firestore: $e');
    }
    // const String apiUrl =
    //     'https://your-api-endpoint.com/events'; // Replace with your API URL
    // try {
    //   final response = await http.post(
    //     Uri.parse(apiUrl),
    //     headers: {
    //       'Content-Type': 'application/json', // Required for JSON data
    //     },
    //     body: jsonEncode({
    //       'events': events, // Same structure as your JSON file logic
    //       'createdAt':
    //           DateTime.now().toIso8601String(), // Optional: Add timestamp
    //     }),
    //   );

    //   if (response.statusCode == 200) {
    //     print('Success! Data sent to server.');
    //     print('Response: ${response.body}');
    //   } else {
    //     print('Error: ${response.statusCode}');
    //     print('Response: ${response.body}');
    //   }
    // } catch (e) {
    //   print('Failed to send data: $e');
    // }
  }

  Future<String> _callGoogleVisionApi(String base64Image) async {
    const apiUrl =
        'https://vision.googleapis.com/v1/images:annotate?key=$_apiKey';

    final requestBody = jsonEncode({
      'requests': [
        {
          'image': {'content': base64Image},
          'features': [
            {'type': 'TEXT_DETECTION'},
          ],
        },
      ],
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return _parseVisionResponse(responseData);
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  String _parseVisionResponse(Map<String, dynamic> response) {
    try {
      if (response['responses'] == null ||
          response['responses'][0]['textAnnotations'] == null) {
        return 'No text found in image';
      }

      final textAnnotations =
          response['responses'][0]['textAnnotations'] as List;
      if (textAnnotations.isEmpty) return 'No text found in image';

      return textAnnotations.first['description'] as String;
    } catch (e) {
      throw Exception('Failed to parse response: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _extractedText = "";
        _vertexAIResponse = "";
        _events = [];
      });
    }
  }

  List<Map<String, dynamic>> parseEventsFromJson(String jsonString) {
    try {
      final cleanedString =
          jsonString.replaceAll('```json', '').replaceAll('```', '').trim();

      final jsonData = json.decode(cleanedString);
      final eventsList = jsonData['events'] as List;
      return eventsList.map((event) {
        return {
          'event': event['event'] ?? 'Unknown',
          'start_date': event['start_date'],
          'end_date': event['end_date'],
        };
      }).toList();
    } catch (e) {
      print('Error parsing JSON: $e');
      return [];
    }
  }

  Future<void> _extractTextAndEvents() async {
    if (_image == null) return;
    if (!_isFirebaseInitialized) {
      setState(() {
        _extractedText = "Error: Firebase not initialized";
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _extractedText = "";
      _vertexAIResponse = "";
      _events = [];
    });

    try {
      final bytes = await _image!.readAsBytes();
      final base64Image = base64Encode(bytes);

      final visionResponse = await _callGoogleVisionApi(base64Image);
      setState(() {
        _extractedText = visionResponse;
      });

      final model = FirebaseVertexAI.instance.generativeModel(
        model: 'gemini-1.5-flash',
      );

      final prompt = Content.text(
        """Extract events and their dates and return nothing else only the json asked for from this text: $visionResponse 
        Return as JSON with event names and start/end dates in this format:
        {
          "events": [
            {
              "event": "Event Name",
              "start_date": "1-1-2022",
              "end_date": "21-2-2022"
            }
          ]
        } that is in the format of DD-MM-YYYY and skip the ones where you don't have enoguh confidence""",
      );

      final response = await model.generateContent([prompt]);
      final events = parseEventsFromJson(response.text ?? '{"events": []}');

      // await _saveToJsonFile(events);
      await _saveToFirestore(events);

      setState(() {
        _events = events;
        _vertexAIResponse = response.text ?? "No response from Vertex AI";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _extractedText = "Error: ${e.toString()}";
        _vertexAIResponse = "Error processing content: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Text & Event Extractor")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  child: Text("Take Photo"),
                ),
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  child: Text("Pick from Gallery"),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (_image != null)
              Image.file(_image!, height: 200, fit: BoxFit.contain),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _extractTextAndEvents,
              child:
                  _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Extract Text & Events"),
            ),
            SizedBox(height: 20),
            // if (_extractedText.isNotEmpty)
            // _buildCard("Extracted Text", _extractedText),
            // if (_vertexAIResponse.isNotEmpty)
            //   _buildCard("Vertex AI Response", _vertexAIResponse),
            if (_events.isNotEmpty) _buildEventCards(),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, String content) => Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          SelectableText(content),
        ],
      ),
    ),
  );

  Widget _buildEventCards() => Column(
    children: [
      Text(
        "Detected Events:",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 8),
      ..._events.map(
        (e) => Card(
          margin: EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(e['event']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Start: ${e['start_date']}"),
                Text("End: ${e['end_date']}"),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditEventScreen(event: e),
                  ),
                ).then((updatedEvent) {
                  // Handle the updated event data here
                });
              },
            ),
          ),
        ),
      ),
    ],
  );
}
