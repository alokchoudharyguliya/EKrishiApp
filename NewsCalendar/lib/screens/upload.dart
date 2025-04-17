import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:newscalendar/constants/constants.dart';
import '../models/events.dart';
import 'edit_event_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import '../firebase_options.dart';

class ImageUploadScreen extends StatefulWidget {
  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  File? _image;
  String _extractedText = "";
  bool _isLoading = false;
  String _vertexAIResponse = "";
  List<Event> _events = [];
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isFirebaseInitialized = false;
  static const String _apiKey = 'AIzaSyAZjj3WDWIPST9r4W0T5QNVv80SGH6jMSM';

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

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      return _parseVisionResponse(jsonDecode(response.body));
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }

  String _parseVisionResponse(Map<String, dynamic> response) {
    final textAnnotations = response['responses']?[0]?['textAnnotations'];
    if (textAnnotations == null || textAnnotations.isEmpty) {
      return 'No text found in image';
    }
    return textAnnotations.first['description'] ?? '';
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _extractedText = "";
        // _aiResponse = "";
        _vertexAIResponse = "";
        _events = [];
      });
    }
  }

  List<Event> parseEventsFromJson(String jsonString) {
    try {
      final cleanedString =
          jsonString.replaceAll('```json', '').replaceAll('```', '').trim();
      final jsonData = json.decode(cleanedString);
      final eventsList = jsonData['events'] as List;

      return eventsList.map((event) {
        DateTime? parseDate(String? dateStr) {
          try {
            return dateStr != null
                ? DateFormat('dd-MM-yyyy').parse(dateStr)
                : null;
          } catch (_) {
            return null;
          }
        }

        return Event(
          id: event['_id']?.toString() ?? '',
          title: event['event'] ?? '',
          startDate: parseDate(event['startDate']) ?? DateTime.now(),
          endDate: parseDate(event['endDate']) ?? DateTime.now(),
          // description: event['description'] ?? '',
          // category: event['category'] ?? '',
          userId: event['userId'] ?? '',
          createdAt: parseDate(event['createdAt']) ?? DateTime.now(),
          updatedAt: parseDate(event['updatedAt']) ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      print('Error parsing events JSON: $e');
      return [];
    }
  }

  Future<void> _saveEventsToBackend(List<Event> events) async {
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/add-events'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'events': events.map((e) => e.toMap()).toList()}),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Events saved successfully!')));
      } else {
        throw Exception('Failed to save events: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving events: $e')));
    } finally {
      setState(() => _isLoading = false);
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

      // if (aiResponse.statusCode == 200) {
      //   final responseData = json.decode(aiResponse.body);
      //   final events = parseEventsFromJson(responseData['processedText']);

      //   setState(() {
      //     _events = events;
      //     _aiResponse = responseData['processedText'];
      //   });
      // } else {
      //   throw Exception('AI processing failed: ${aiResponse.body}');
      // }
      // }
      final response = await model.generateContent([prompt]);
      final events = parseEventsFromJson(response.text ?? '{"events": []}');

      // await _saveToJsonFile(events);
      // await _saveToFirestore(events);

      setState(() {
        _events = events;
        _vertexAIResponse = response.text ?? "No response from Vertex AI";
        _extractedText = "Error: ${visionResponse.toString()}";
        // _vertexAIResponse = "Error processing content: ${e.toString()}";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _extractedText = "Error: $e";
        _vertexAIResponse = "AI Error: $e";
      });
    } finally {
      setState(() => _isLoading = false);
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
              Image.file(_image!, height: 200, fit: BoxFit.cover),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _extractTextAndEvents,
              child:
                  _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Events"),
            ),
            SizedBox(height: 20),
            if (_extractedText.isNotEmpty)
              Text(
                "Extracted Text:\n$_extractedText",
                textAlign: TextAlign.center,
              ),
            if (_events.isNotEmpty) ...[
              SizedBox(height: 20),
              Text(
                "Detected Events:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _events.length,
                itemBuilder: (context, index) {
                  final e = _events[index];
                  return ListTile(
                    title: Text(e.title),
                    subtitle: Text(
                      '${DateFormat('dd MMM yyyy').format(e.startDate)} - ${DateFormat('dd MMM yyyy').format(e.endDate!)}\n}${e.description}',
                    ),
                  );
                },
              ),
              ElevatedButton(
                onPressed:
                    _isLoading ? null : () => _saveEventsToBackend(_events),
                child: Text("Save Events"),
              ),
            ],
            FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditEventScreen(editing: false),
                  ),
                );
              },
              child: Icon(Icons.add),
              tooltip: "Add Event Manually",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCards() => Column(
    children: [
      Text(
        "Detected Events:",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 8),
      ..._events.map(
        (event) => Card(
          margin: EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(event.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Start: ${DateFormat('dd-MM-yyyy').format(event.start_date)}",
                ),
                if (event.end_date != null)
                  Text(
                    "End: ${DateFormat('dd-MM-yyyy').format(event.end_date!)}",
                  ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditEventScreen(event: event),
                  ),
                ).then((updatedEvent) {
                  if (updatedEvent != null) {
                    setState(() {
                      final index = _events.indexWhere(
                        (e) => e.id == updatedEvent.id,
                      );
                      if (index != -1) _events[index] = updatedEvent;
                    });
                  }
                });
              },
            ),
          ),
        ),
      ),
    ],
  );
}
