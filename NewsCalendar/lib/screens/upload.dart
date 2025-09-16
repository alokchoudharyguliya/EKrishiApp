import 'package:http/http.dart' as http;
import '../utils/imports.dart';
import 'package:flutter/material.dart';
import '../models/events.dart' as eventModel;

class ImageUploadScreen extends StatefulWidget {
  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  File? _image;
  String _extractedText = "";
  bool _isLoading = false;
  String _vertexAIResponse = "";
  List<eventModel.Event> _events = [];
  bool _isFirebaseInitialized = false;
  static const String _apiKey = 'AIzaSyAZjj3WDWIPST9r4W0T5QNVv80SGH6jMSM';
  final Uuid _uuid = Uuid(); // UUID generator

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
        _vertexAIResponse = "";
        _events = [];
      });
    }
  }

  List<eventModel.Event> parseEventsFromResponse(String responseText) {
    try {
      final cleanedString =
          responseText.replaceAll('```json', '').replaceAll('```', '').trim();
      final jsonData = json.decode(cleanedString);
      final eventsList = jsonData['events'] as List;

      return eventsList.map((eventData) {
        DateTime? parseDate(String? dateStr) {
          if (dateStr == null) return null;
          try {
            return DateFormat('dd-MM-yyyy').parse(dateStr);
          } catch (e) {
            print('Error parsing date $dateStr: $e');
            return null;
          }
        }

        final startDate = parseDate(eventData['start_date']) ?? DateTime.now();
        final endDate = parseDate(eventData['end_date']) ?? startDate;

        return eventModel.Event(
          lastUpdated: DateTime.now(),
          id: _uuid.v4(), // Generate unique ID
          title: eventData['event'] ?? 'Untitled Event',
          startDate: startDate,
          endDate: endDate,
          description: eventData['description'] ?? '',
          userId: '', // Set as needed
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }).toList();
    } catch (e) {
      print('Error parsing events from response: $e');
      return [];
    }
  }

  Future<void> _saveEventsToBackend(List<eventModel.Event> events) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userService = Provider.of<UserService>(context, listen: false);

    final String? token = authService.token;
    print(token);
    setState(() => _isLoading = true);

    try {
      // Get userData from UserService (which uses FlutterSecureStorage)
      dynamic userData = await userService.getUserData();
      final now = DateTime.now().toIso8601String();
      final eventsWithData =
          events
              .map(
                (e) => {
                  'title': e.title,
                  'start_date': e.startDate.toString(),
                  'end_date': e.endDate!.toString(),
                  'description':
                      e.description ?? '', // Default empty string if null
                  'userId': userData['_id'], // From local storage
                  'createdAt': now.toString(), // Current time for creation
                  'updatedAt': now.toString(), // Current time for update
                  // Add any other fields from your Event model
                },
              )
              .toList();
      final response = await http.post(
        Uri.parse('$BASE_URL/add-events'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'events': eventsWithData}),
      );
      print("00000000000000000000token");

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Events saved successfully!')));
      } else {
        throw Exception('Failed to save events: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving events:---------- $e')),
      );
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
        """Extract events and their dates and return nothing else only the json asked for from this text and nothing else...strictly nothing else: $visionResponse 
        Return as JSON with event names and start/end dates in this format:
        {
          "events": [
            {
              "event": "Event Name",
              "start_date": "1-1-2022",
              "end_date": "21-2-2022"
            }
          ]
        } that is in the format of DD-MM-YYYY and skip the events that you are not confident about""",
      );
      final response = await model.generateContent([prompt]);
      print(response.text);

      // Parse the response and convert dates
      final events = parseEventsFromResponse(response.text ?? '{"events": []}');

      setState(() {
        _events = events;
        _vertexAIResponse = response.text ?? "No response from Vertex AI";
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
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _extractTextAndEvents,
                child:
                    _isLoading
                        ? CircularProgressIndicator(
                          color: const Color.fromARGB(255, 47, 2, 106),
                        )
                        : Text("Extract Events"),
              ),
            ),
            SizedBox(height: 20),
            if (_events.isNotEmpty) ...[
              _buildEventCards(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    _isLoading ? null : () => _saveEventsToBackend(_events),
                child: Text("Save Events"),
              ),
            ],
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
          key: ValueKey(event.id), // Use event.id as unique key
          margin: EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(event.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Start: ${DateFormat('dd-MM-yyyy').format(event.startDate)}",
                ),
                if (event.endDate != null && event.endDate != event.startDate)
                  Text(
                    "End: ${DateFormat('dd-MM-yyyy').format(event.endDate!)}",
                  ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async {
                final updatedEvent = await showDialog<eventModel.Event>(
                  context: context,
                  builder: (context) {
                    return Dialog(child: MiniEdit(event: event, editing: true));
                  },
                );

                if (updatedEvent != null && mounted) {
                  setState(() {
                    final index = _events.indexWhere(
                      (e) => e.id == updatedEvent.id,
                    );
                    if (index != -1) {
                      _events[index] = updatedEvent;
                    }
                  });
                }
              },
            ),
          ),
        ),
      ),
    ],
  );
}
