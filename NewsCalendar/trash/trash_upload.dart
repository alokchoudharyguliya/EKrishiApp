// // import 'dart:io';
// // import 'dart:convert';
// // import 'dart:typed_data';
// // import 'package:flutter/material.dart';
// // import 'package:image_picker/image_picker.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:path_provider/path_provider.dart';
// // import 'package:path/path.dart' as path;

// // class ImageUploadScreen extends StatefulWidget {
// //   @override
// //   _ImageUploadScreenState createState() => _ImageUploadScreenState();
// // }

// // class _ImageUploadScreenState extends State<ImageUploadScreen> {
// //   File? _image;
// //   String? _extractedText;
// //   bool _isLoading = false;

// //   Future<String> _callGoogleVisionApi(String base64Image) async {
// //     const apiKey = 'b29b8f5d888b57a7ed4e88c22c4d5eea06f16197';
// //     // 'AIzaSyCV0xPXeqkhewdbLGUP9I9kjyIyi_GyyCU'; // Replace with your actual API key
// //     const apiUrl =
// //         'https://vision.googleapis.com/v1/images:annotate?key=$apiKey';

// //     final requestBody = jsonEncode({
// //       'requests': [
// //         {
// //           'image': {'content': base64Image},
// //           'features': [
// //             {'type': 'TEXT_DETECTION'},
// //           ],
// //         },
// //       ],
// //     });
// //     Future<String> _callGoogleVisionApi(String base64Image) async {
// //       const serverUrl =
// //           'vision-api-service@possible-jetty-456808-f9.iam.gserviceaccount.com'; // Replace with your server URL

// //       final response = await http.post(
// //         Uri.parse(serverUrl),
// //         headers: {'Content-Type': 'application/json'},
// //         body: jsonEncode({'imageBase64': base64Image}),
// //       );

// //       if (response.statusCode == 200) {
// //         final responseData = jsonDecode(response.body);
// //         return responseData['text'] ?? 'No text found';
// //       } else {
// //         throw Exception(
// //           'Failed to extract text: ${response.statusCode} - ${response.body}',
// //         );
// //       }
// //     }

// //     final response = await http.post(
// //       Uri.parse(apiUrl),
// //       headers: {'Content-Type': 'application/json'},
// //       body: requestBody,
// //     );

// //     if (response.statusCode == 200) {
// //       final responseData = jsonDecode(response.body);
// //       return _parseVisionResponse(responseData);
// //     } else {
// //       throw Exception(
// //         'Failed to extract text: ${response.statusCode} - ${response.body}',
// //       );
// //     }
// //   }

// //   String _parseVisionResponse(Map<String, dynamic> response) {
// //     try {
// //       final textAnnotations =
// //           response['responses'][0]['textAnnotations'] as List;
// //       if (textAnnotations.isEmpty) return 'No text found in image';

// //       // The first item contains all text in a single string
// //       return textAnnotations.first['description'] as String;
// //     } catch (e) {
// //       throw Exception('Failed to parse response: $e');
// //     }
// //   }

// //   Future<void> _pickImage(ImageSource source) async {
// //     final picker = ImagePicker();
// //     final pickedFile = await picker.pickImage(source: source);

// //     if (pickedFile != null) {
// //       setState(() {
// //         _image = File(pickedFile.path);
// //         _extractedText = null;
// //       });
// //     }
// //   }

// //   Future<void> _extractText() async {
// //     if (_image == null) return;

// //     setState(() {
// //       _isLoading = true;
// //     });

// //     try {
// //       // Convert image to base64
// //       final bytes = await _image!.readAsBytes();
// //       final base64Image = base64Encode(bytes);

// //       // Call your backend service (we'll implement this in Part 2)
// //       // For now, we'll just mock the response
// //       final response = await _callGoogleVisionApi(base64Image);

// //       // Mock response for testing UI
// //       await Future.delayed(Duration(seconds: 2)); // Simulate network delay
// //       setState(() {
// //         _extractedText =
// //             "This is a mock response.\nActual text extraction will be implemented in Part 2.";
// //         _isLoading = false;
// //       });
// //     } catch (e) {
// //       setState(() {
// //         _extractedText = "Error: ${e.toString()}";
// //         _isLoading = false;
// //       });
// //     }
// //   }

// //   // // This will be implemented in Part 2 with the actual Google Cloud Vision API call
// //   // Future<String> _callGoogleVisionApi(String base64Image) async {
// //   //   // TODO: Implement in Part 2
// //   //   throw UnimplementedError("This will be implemented in Part 2");
// //   // }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text('Text Extraction')),
// //       body: SingleChildScrollView(
// //         padding: EdgeInsets.all(16.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.stretch,
// //           children: [
// //             // Image selection buttons
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //               children: [
// //                 ElevatedButton(
// //                   onPressed: () => _pickImage(ImageSource.camera),
// //                   child: Text('Take Photo'),
// //                 ),
// //                 ElevatedButton(
// //                   onPressed: () => _pickImage(ImageSource.gallery),
// //                   child: Text('Choose from Gallery'),
// //                 ),
// //               ],
// //             ),
// //             SizedBox(height: 20),

// //             // Preview image
// //             if (_image != null)
// //               Container(
// //                 height: 200,
// //                 decoration: BoxDecoration(
// //                   border: Border.all(color: Colors.grey),
// //                 ),
// //                 child: Image.file(_image!, fit: BoxFit.contain),
// //               )
// //             else
// //               Container(
// //                 height: 200,
// //                 decoration: BoxDecoration(
// //                   border: Border.all(color: Colors.grey),
// //                 ),
// //                 child: Center(child: Text('No image selected')),
// //               ),
// //             SizedBox(height: 20),

// //             // Extract text button
// //             ElevatedButton(
// //               onPressed: _image != null && !_isLoading ? _extractText : null,
// //               child:
// //                   _isLoading
// //                       ? CircularProgressIndicator(color: Colors.white)
// //                       : Text('Extract Text'),
// //             ),
// //             SizedBox(height: 20),

// //             // Extracted text
// //             if (_extractedText != null)
// //               Card(
// //                 child: Padding(
// //                   padding: EdgeInsets.all(16.0),
// //                   child: SelectableText(
// //                     _extractedText!,
// //                     style: TextStyle(fontSize: 16),
// //                   ),
// //                 ),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'firebase_options.dart';
// final credentials = auth.ServiceAccountCredentials.fromJson(
//   json.decode(await rootBundle.loadString('assets/service-account-key.json'))
// );

// final client = await auth.clientViaServiceAccount(credentials, [
//   'https://www.googleapis.com/auth/cloud-platform',
// ]);



  // Future<void> _extractText() async {
  //   if (_image == null) return;

  //   setState(() {
  //     _isLoading = true;
  //     _extractedText = null;
  //   });

  //   try {
  //     final bytes = await _image!.readAsBytes();
  //     final base64Image = base64Encode(bytes);

  //     // Call the actual API (removed mock response)
  //     final extractedText = await _callGoogleVisionApi(base64Image);

  //     setState(() {
  //       _extractedText = extractedText;
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _extractedText = "Error: ${e.toString()}";
  //       _isLoading = false;
  //     });
  //   }
  // }


        // print(replacedText);
      // Step 3: Call Natural Language API to detect events & dates
      // final languageResponse = await http.post(
      //   Uri.parse(
      //     'https://us-central1-aiplatform.googleapis.com/v1/projects/bamboo-research-452705-u8/locations/us-central1/publishers/google/models/text-bison:predict',
      //   ),
      //   headers: {
      //     'Content-Type': 'application/json',
      //     'Authorization':
      //         'Bearer ya29.a0AZYkNZgU3e7LMhIemoOmGZF7CiYHTVHy9wUmqJs9ymIfcLZnfjBL8HPmvxTPFUydkusuLyTukpZaEvadM7SdUV4gG_bGjxs93Ihddl4pzCV-FuvgvHLqihY-FbAAEKH1aWB2ceqzXfZ_IztUhfhzilMPn3qbOydOBda5HwR20jwZggaCgYKAcQSARISFQHGX2MiAENU-a8zGhWMshPHIh7gDg0181', // You'll need to handle authentication
      //   },
      //   body: jsonEncode({
      //     "instances": [
      //       {"prompt": "Who is the president of the US?"},
      //     ],
      //     "parameters": {
      //       "temperature": 0.2,
      //       "maxOutputTokens": 256,
      //       "topK": 40,
      //       "topP": 0.95,
      //     },
      //   }),
      // );
      // final languageResponse = await http.post(
      //   Uri.parse(
      //     'https://language.googleapis.com/v1/documents:analyzeEntities?key=$_apiKey',
      //   ),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({
      //     "document": {
      //       "type": "PLAIN_TEXT",
      //       "content": """Whos is president of US?""",
      //       //               """Extract events and their dates from this text $replacedText and return as JSON with event names and start/end dates:  like this {
      //       // "events": [
      //       //   {
      //       //     "event": "A",
      //       //     "start_date": "1 July 2022",
      //       //     "end_date": "1 November 2022"
      //       //   },
      //       //   {
      //       //     "event": "V",
      //       //     "start_date": "12 November 2022",
      //       //     "end_date": "13 November 2022"
      //       //   },
      //       //   {
      //       //     "event": "C",
      //       //     "start_date": "14 November 2022",
      //       //     "end_date": "19 November 2022"
      //       //   },
      //       //   ]
      //       // }
      //       // """,
      //       // .body["responses"][0]["textAnnotations"]["description"],
      //     },
      //     "encodingType": "UTF8",
      //   }),
      // );

      // final languageResponse = await http.post(
      //   Uri.parse(
      //     'https://language.googleapis.com/v1/documents:analyzeEntities?key=$_apiKey',
      //   ),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({
      //     "document": {
      //       "type": "PLAIN_TEXT",
      //       "content": fullText,
      //       """Extract events and their dates from this text and return as JSON with event names and start/end dates:
      // """,
      //     },
      //     "encodingType": "UTF8",
      //     // These features might help with date extraction
      //     "features": {
      //       "extractEntities": true,
      //       "extractDocumentSentiment": false,
      //       "extractEntitySentiment": false,
      //       "classifyText": false,
      //     },
      //   }),
      // );

      // if (languageResponse.statusCode != 200) {
      //   throw Exception("Language API Error: ${languageResponse.body}");
      // }

      // final languageData = jsonDecode(languageResponse.body);
      // print(languageData.toString());
      // final events = null;
      // final events = _extractEventsWithDates(
      //   languageData['entities'],
      //   languageResponse.body,
      // );

      //     setState(() {
      //       _extractedText = languageResponse.body;
      //       // _events = events;
      //       _isLoading = false;
      //     });



      
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: Text('Text Extraction')),
  //     body: SingleChildScrollView(
  //       padding: EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.stretch,
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: [
  //               ElevatedButton(
  //                 onPressed: () => _pickImage(ImageSource.camera),
  //                 child: Text('Take Photo'),
  //               ),
  //               ElevatedButton(
  //                 onPressed: () => _pickImage(ImageSource.gallery),
  //                 child: Text('Choose from Gallery'),
  //               ),
  //             ],
  //           ),
  //           SizedBox(height: 20),

  //           if (_image != null)
  //             Container(
  //               height: 200,
  //               decoration: BoxDecoration(
  //                 border: Border.all(color: Colors.grey),
  //               ),
  //               child: Image.file(_image!, fit: BoxFit.contain),
  //             )
  //           else
  //             Container(
  //               height: 200,
  //               decoration: BoxDecoration(
  //                 border: Border.all(color: Colors.grey),
  //               ),
  //               child: Center(child: Text('No image selected')),
  //             ),
  //           SizedBox(height: 20),

  //           ElevatedButton(
  //             onPressed:
  //                 _image != null && !_isLoading ? _extractTextAndEvents : null,
  //             child:
  //                 _isLoading
  //                     ? CircularProgressIndicator(color: Colors.white)
  //                     : Text('Extract Text'),
  //           ),
  //           SizedBox(height: 20),

  //           if (_isLoading)
//   //             Center(child: CircularProgressIndicator())
//   //           else if (_extractedText != null)
//   //             Card(
//   //               child: Padding(
//   //                 padding: EdgeInsets.all(16.0),
//   //                 child: SelectableText(
//   //                   _extractedText!,
//   //                   style: TextStyle(fontSize: 16),
//   //                 ),
//   //               ),
//   //             ),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }
// }

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class ChatScreen extends StatefulWidget {
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _textController = TextEditingController();
//   final List<String> _messages = [];
//   final String _apiKey =
//       'AIzaSyAZjj3WDWIPST9r4W0T5QNVv80SGH6jMSM'; // VERY INSECURE!
//   final String _modelName = 'gemini-pro';
//   final String _vertexAiEndpoint =
//       'https://us-central1-aiplatform.googleapis.com/v1/projects/project=bamboo-research-452705-u8/locations/us-central1/publishers/google/models/gemini-pro:generateContent'; // Replace with your project ID and desired endpoint

//   Future<void> _sendMessage(String message) async {
//     message = "Who is president of US";
//     setState(() {
//       _messages.add("You: $message");
//     });
//     _textController.clear();

//     try {
//       final response = await http.post(
//         Uri.parse(_vertexAiEndpoint),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization':
//               'Bearer ya29.a0AZYkNZgNtKM0IsxrXKsg2lzsupUTUehmKdnMpNstVgLPY6xBSWRqebGpXX_u3e_iCgeuWhfMI71CDw_tEFpx3rFMdSfTsd6Hzk8LsvYGZlN-huoypM5ixJYvlnt4UIXXOIwdi3Fm36HMQZmDugwyVvT7fkrkxu1crKiJecqr44V4f0l-qTsYu3m9RXS0v0rZxsYVnQ338PfxQRgAvsLjnaR7U7YItch6yA0rpRO9l2UV2v3M4nxhi5tIg7gvFq0c_wRIrIoTN0xJO9JouLVFxuiyX7wWg9LUc0z1PW1BmlZNXu716_4e2KCtOWrFkndfthVIzId3JiTWDJuvw2W5fPTi71G36qYvOORfddQTMa4e7ZkOKWGJkTcbK8praZo8SSJ1KcxG3bJbfiMSwNaqh8G75lvujvpuHFMpaCgYKAegSARISFQHGX2Mipfhsey01Eru5dMN4uXlLAA0427', // You'd need to figure out how to get a valid token (API Key is insecure)
//         },
//         body: jsonEncode({
//           'contents': [
//             {
//               'role': 'user',
//               'parts': [
//                 {'text': message},
//               ],
//             },
//           ],
//         }),
//       );

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         print(responseData.toString());
//         final botResponse =
//             responseData['candidates'][0]['content']['parts'][0]['text'];
//         setState(() {
//           _messages.add("Bot: $botResponse");
//         });
//       } else {
//         setState(() {
//           _messages.add("Error: Could not connect to Vertex AI.");
//         });
//         print('Vertex AI error: ${response.statusCode}, ${response.body}');
//       }
//     } catch (e) {
//       setState(() {
//         _messages.add("Error: Network issue.");
//       });
//       print('Network error: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Chatbot (VERY INSECURE)')),
//       body: Column(
//         // ... (UI code as in the backend example)
//         children: [
//           ElevatedButton(
//             onPressed: (() => {_sendMessage("Hey")}),
//             child: Text("data"),
//           ),
//         ],
//       ),
//     );
//   }
// }



  // Future<void> _extractTextAndEvents() async {
  //   if (_image == null) return;

  //   await Firebase.initializeApp(
  //     options: DefaultFirebaseOptions.currentPlatform,
  //   );

  //   // Initialize the Vertex AI service and create a `GenerativeModel` instance
  //   // Specify a model that supports your use case
  //   final model = FirebaseVertexAI.instance.generativeModel(
  //     model: 'gemini-2.0-flash',
  //   );

  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     // Provide a prompt that contains text
  //     final prompt = [Content.text('Who is President of US?')];

  //     // To generate text output, call generateContent with the text input
  //     final response = await model.generateContent(prompt);
  //     print(response.text);
  //     // Step 1: Convert image to Base64
  //     final bytes = await _image!.readAsBytes();
  //     final base64Image = base64Encode(bytes);

  //     // Step 2: Call Google Vision API
  //     final visionResponse = await http.post(
  //       Uri.parse(
  //         'https://vision.googleapis.com/v1/images:annotate?key=$_apiKey',
  //       ),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({
  //         "requests": [
  //           {
  //             "image": {"content": base64Image},
  //             "features": [
  //               {"type": "TEXT_DETECTION"},
  //             ],
  //           },
  //         ],
  //       }),
  //     );

  //     if (visionResponse.statusCode != 200) {
  //       throw Exception("Vision API Error: ${visionResponse.body}");
  //     }
  //     print(visionResponse.body);

  //     final visionData = jsonDecode(visionResponse.body);
  //     // final fullText = visionData['responses'][0]['textAnnotations'][0];
  //     // String escapedText = fullText.replaceAll('\n', '\\n');
  //     final fullText =
  //         visionData['responses'][0]['textAnnotations'][0]['description'];
  //     // To print with \n visible:
  //     final replacedText = fullText.replaceAll('\n', '\\n');
  //   } catch (e) {
  //     setState(() {
  //       _extractedText = "Error: $e";
  //       _isLoading = false;
  //     });
  //   }
  // }



//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Vertex AI Test")),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           children: [
//             ElevatedButton(
//               onPressed: _testVertexAI,
//               child:
//                   _isLoading
//                       ? CircularProgressIndicator(color: Colors.white)
//                       : Text("Test Vertex AI"),
//             ),
//             SizedBox(height: 20),
//             if (_vertexAIResponse.isNotEmpty)
//               Card(
//                 child: Padding(
//                   padding: EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Vertex AI Response:",
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       SizedBox(height: 8),
//                       Text(_vertexAIResponse),
//                     ],
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// import 'dart:io';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:googleapis_auth/googleapis_auth.dart' as auth;
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_vertexai/firebase_vertexai.dart';
// import '../firebase_options.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:path_provider/path_provider.dart';

// class ImageUploadScreen extends StatefulWidget {
//   @override
//   _ImageUploadScreenState createState() => _ImageUploadScreenState();
// }

// class _ImageUploadScreenState extends State<ImageUploadScreen> {
//   File? _image;
//   String _extractedText = "";
//   List<Map<String, dynamic>> _events = [];
//   bool _isLoading = false;
//   String _vertexAIResponse = "";
//   static const String _apiKey = 'AIzaSyAZjj3WDWIPST9r4W0T5QNVv80SGH6jMSM';

//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<void> _initializeFirebase() async {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//   }

//   Future<void> _saveToJsonFile(List<Map<String, dynamic>> events) async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final file = File('${directory.path}/events.json');
//       await file.writeAsString(jsonEncode(events));
//       print('Events saved to ${file.path}');
//     } catch (e) {
//       print('Error saving to JSON file: $e');
//     }
//   }

//   Future<void> _saveToFirestore(List<Map<String, dynamic>> events) async {
//     try {
//       final collectionRef = _firestore.collection('extracted_events');
//       final batch = _firestore.batch();

//       for (var event in events) {
//         final docRef = collectionRef.doc(); // Auto-generate document ID
//         batch.set(docRef, {
//           'event': event['event'],
//           'dates': event['dates'],
//           'confidence': event['confidence'],
//           'timestamp': FieldValue.serverTimestamp(),
//         });
//       }

//       await batch.commit();
//       print('Events saved to Firestore');
//     } catch (e) {
//       print('Error saving to Firestore: $e');
//     }
//   }

//   // Corrected API call method
//   Future<String> _callGoogleVisionApi(String base64Image) async {
//     // Replace with your actual API key
//     const apiUrl =
//         'https://vision.googleapis.com/v1/images:annotate?key=$_apiKey';

//     final requestBody = jsonEncode({
//       'requests': [
//         {
//           'image': {'content': base64Image},
//           'features': [
//             {'type': 'TEXT_DETECTION'},
//           ],
//         },
//       ],
//     });

//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: requestBody,
//       );

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         return _parseVisionResponse(responseData);
//       } else {
//         throw Exception('API Error: ${response.statusCode} - ${response.body}');
//       }
//     } catch (e) {
//       throw Exception('Network Error: ${e.toString()}');
//     }
//   }

//   String _parseVisionResponse(Map<String, dynamic> response) {
//     try {
//       if (response['responses'] == null ||
//           response['responses'][0]['textAnnotations'] == null) {
//         return 'No text found in image';
//       }

//       final textAnnotations =
//           response['responses'][0]['textAnnotations'] as List;
//       if (textAnnotations.isEmpty) return 'No text found in image';

//       return textAnnotations.first['description'] as String;
//     } catch (e) {
//       throw Exception('Failed to parse response: $e');
//     }
//   }

//   Future<void> _pickImage(ImageSource source) async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: source);

//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//         _extractedText = "";
//         _events = [];
//       });
//     }
//   }

//   List<Map<String, dynamic>> parseEventsFromJson(String jsonString) {
//     try {
//       // Remove the ```json and ``` markers if present
//       final cleanedString =
//           jsonString.replaceAll('```json', '').replaceAll('```', '').trim();

//       // Parse the JSON string
//       final jsonData = json.decode(cleanedString);

//       // Extract the events array
//       final eventsList = jsonData['events'] as List;

//       // Convert to the desired format
//       return eventsList.map((event) {
//         return {
//           'event': event['event'],
//           'start_date': event['start_date'],
//           'end_date': event['end_date'],
//         };
//       }).toList();
//     } catch (e) {
//       print('Error parsing JSON: $e');
//       return [];
//     }
//   }

//   Future<void> _extractTextAndEvents() async {
//     if (_image == null) return;

//     await _initializeFirebase();

//     setState(() {
//       _isLoading = true;
//       _extractedText = "";
//       _vertexAIResponse = "";
//     });

//     try {
//       // Convert image to Base64
//       final bytes = await _image!.readAsBytes();
//       final base64Image = base64Encode(bytes);

//       // Call Google Vision API
//       final visionResponse = await http.post(
//         Uri.parse(
//           'https://vision.googleapis.com/v1/images:annotate?key=$_apiKey',
//         ),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           "requests": [
//             {
//               "image": {"content": base64Image},
//               "features": [
//                 {"type": "TEXT_DETECTION"},
//               ],
//             },
//           ],
//         }),
//       );

//       if (visionResponse.statusCode != 200) {
//         throw Exception("Vision API Error: ${visionResponse.body}");
//       }

//       final visionData = jsonDecode(visionResponse.body);
//       final fullText =
//           visionData['responses'][0]['textAnnotations'][0]['description'];

//       final model = FirebaseVertexAI.instance.generativeModel(
//         model: 'gemini-1.5-flash',
//       );

//       final prompt = Content.text(
//         """Extract events and their dates from this text $fullText and return as JSON with event names and start/end dates:  like this
//         {events:
//         [
//           {
//             "event": "A",
//             "start_date": "1 July 2022",
//             "end_date": "1 November 2022"
//           },
//           {
//             "event": "V",
//             "start_date": "12 November 2022",
//             "end_date": "13 November 2022"
//           }
//         ]}""",
//       );

//       // Using await for better readability and error handling
//       final content = await model.generateContent([prompt]);
//       final events = parseEventsFromJson(content.text ?? '{"events": []}');

//       await _saveToJsonFile(events);
//       await _saveToFirestore(events);

//       setState(() {
//         _extractedText = fullText;
//         _vertexAIResponse = events.isNotEmpty ? "$events" : "No events found";
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _extractedText = "Error: ${e.toString()}";
//         _vertexAIResponse = "Error processing content: ${e.toString()}";
//         _isLoading = false;
//       });
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Text & Event Extractor")),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton(
//                   onPressed: () => _pickImage(ImageSource.camera),
//                   child: Text("Take Photo"),
//                 ),
//                 ElevatedButton(
//                   onPressed: () => _pickImage(ImageSource.gallery),
//                   child: Text("Pick from Gallery"),
//                 ),
//               ],
//             ),
//             SizedBox(height: 20),
//             if (_image != null)
//               Image.file(_image!, height: 200, fit: BoxFit.contain),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _extractTextAndEvents,
//               child:
//                   _isLoading
//                       ? CircularProgressIndicator(color: Colors.white)
//                       : Text("Extract Text & Events"),
//             ),
//             SizedBox(height: 20),
//             if (_extractedText!.isNotEmpty)
//               Card(
//                 child: Padding(
//                   padding: EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Extracted Text:",
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       SizedBox(height: 8),
//                       Text(_extractedText),
//                     ],
//                   ),
//                 ),
//               ),
//             if (_events.isNotEmpty) ...[
//               SizedBox(height: 20),
//               Text(
//                 "Detected Events:",
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//               ),
//               ..._events
//                   .map(
//                     (event) => Card(
//                       margin: EdgeInsets.symmetric(vertical: 8),
//                       child: ListTile(
//                         title: Text(event['event']),
//                         subtitle: Text(
//                           "Dates: ${event['dates'].join(', ')}\n"
//                           "Confidence: ${event['confidence']}",
//                         ),
//                       ),
//                     ),
//                   )
//                   .toList(),
//             ],
//             if (_vertexAIResponse.isNotEmpty)
//               Card(
//                 child: Padding(
//                   padding: EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Vertex AI Analysis:",
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       SizedBox(height: 8),
//                       Text(_vertexAIResponse),
//                     ],
//                   ),
//                 ),
//               ),
//             SizedBox(height: 20),
//             if (_extractedText.isNotEmpty)
//               _buildCard("Extracted Text", _extractedText),
//             if (_vertexAIResponse.isNotEmpty)
//               _buildCard("Vertex AI Response", _vertexAIResponse),
//             if (_events.isNotEmpty) _buildEventCards(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCard(String title, String content) => Card(
//     child: Padding(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//           ),
//           SizedBox(height: 8),
//           SelectableText(content),
//         ],
//       ),
//     ),
//   );

//   Widget _buildEventCards() => Column(
//     children: [
//       Text(
//         "Detected Events:",
//         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//       ),
//       ..._events.map(
//         (e) => Card(
//           child: ListTile(
//             title: Text(e['event']),
//             subtitle: Text("Start: ${e['start_date']}\nEnd: ${e['end_date']}"),
//           ),
//         ),
//       ),
//     ],
//   );
// }

// import 'dart:io';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:googleapis_auth/googleapis_auth.dart' as auth;
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_vertexai/firebase_vertexai.dart';
// import '../firebase_options.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:path_provider/path_provider.dart';

// class ImageUploadScreen extends StatefulWidget {
//   @override
//   _ImageUploadScreenState createState() => _ImageUploadScreenState();
// }

// class _ImageUploadScreenState extends State<ImageUploadScreen> {
//   File? _image;
//   String _extractedText = "";
//   List<Map<String, dynamic>> _events = [];
//   bool _isLoading = false;
//   String _vertexAIResponse = "";
//   static const String _apiKey = 'AIzaSyAZjj3WDWIPST9r4W0T5QNVv80SGH6jMSM';

//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<void> _initializeFirebase() async {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//   }

//   Future<void> _saveToJsonFile(List<Map<String, dynamic>> events) async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final file = File('${directory.path}/events.json');
//       await file.writeAsString(jsonEncode({'events': events}));
//       print('Events saved to ${file.path}');
//     } catch (e) {
//       print('Error saving to JSON file: $e');
//     }
//   }

//   Future<void> _saveToFirestore(List<Map<String, dynamic>> events) async {
//     try {
//       final collectionRef = _firestore.collection('extracted_events');
//       final batch = _firestore.batch();

//       for (var event in events) {
//         final docRef = collectionRef.doc(); // Auto-generate document ID
//         batch.set(docRef, {
//           'event': event['event'],
//           'start_date': event['start_date'],
//           'end_date': event['end_date'],
//           'timestamp': FieldValue.serverTimestamp(),
//         });
//       }

//       await batch.commit();
//       print('Events saved to Firestore');
//     } catch (e) {
//       print('Error saving to Firestore: $e');
//     }
//   }

//   Future<String> _callGoogleVisionApi(String base64Image) async {
//     const apiUrl =
//         'https://vision.googleapis.com/v1/images:annotate?key=$_apiKey';

//     final requestBody = jsonEncode({
//       'requests': [
//         {
//           'image': {'content': base64Image},
//           'features': [
//             {'type': 'TEXT_DETECTION'},
//           ],
//         },
//       ],
//     });

//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: requestBody,
//       );

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         return _parseVisionResponse(responseData);
//       } else {
//         throw Exception('API Error: ${response.statusCode} - ${response.body}');
//       }
//     } catch (e) {
//       throw Exception('Network Error: ${e.toString()}');
//     }
//   }

//   String _parseVisionResponse(Map<String, dynamic> response) {
//     try {
//       if (response['responses'] == null ||
//           response['responses'][0]['textAnnotations'] == null) {
//         return 'No text found in image';
//       }

//       final textAnnotations =
//           response['responses'][0]['textAnnotations'] as List;
//       if (textAnnotations.isEmpty) return 'No text found in image';

//       return textAnnotations.first['description'] as String;
//     } catch (e) {
//       throw Exception('Failed to parse response: $e');
//     }
//   }

//   Future<void> _pickImage(ImageSource source) async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: source);

//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//         _extractedText = "";
//         _events = [];
//         _vertexAIResponse = "";
//       });
//     }
//   }

//   List<Map<String, dynamic>> _parseVertexAIResponse(String response) {
//     try {
//       // Clean the response string to make it valid JSON
//       String cleanedResponse = response.trim();

//       // Remove markdown code block notation if present
//       if (cleanedResponse.startsWith('```json')) {
//         cleanedResponse = cleanedResponse.substring(7);
//       }
//       if (cleanedResponse.endsWith('```')) {
//         cleanedResponse = cleanedResponse.substring(0, cleanedResponse.length - 3);
//       }

//       // Parse the JSON
//       final Map<String, dynamic> parsed = jsonDecode(cleanedResponse);

//       // Extract events array
//       final List<dynamic> eventsList = parsed['events'] as List;

//       // Convert to List<Map<String, dynamic>>
//       return eventsList.map((event) => {
//         'event': event['event'] as String,
//         'start_date': event['start_date'] as String,
//         'end_date': event['end_date'] as String,
//       }).toList();
//     } catch (e) {
//       print('Error parsing Vertex AI response: $e');
//       throw Exception('Failed to parse Vertex AI response: $e');
//     }
//   }

//   Future<void> _extractTextAndEvents() async {
//     if (_image == null) return;

//     await _initializeFirebase();

//     final model = FirebaseVertexAI.instance.generativeModel(
//       model: 'gemini-1.5-flash',
//     );

//     setState(() {
//       _isLoading = true;
//       _extractedText = "";
//       _vertexAIResponse = "";
//       _events = [];
//     });

//     try {
//       // Convert image to Base64
//       final bytes = await _image!.readAsBytes();
//       final base64Image = base64Encode(bytes);

//       // Call Google Vision API
//       final visionResponse = await http.post(
//         Uri.parse(
//           'https://vision.googleapis.com/v1/images:annotate?key=$_apiKey',
//         ),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           "requests": [
//             {
//               "image": {"content": base64Image},
//               "features": [
//                 {"type": "TEXT_DETECTION"},
//               ],
//             },
//           ],
//         }),
//       );

//       if (visionResponse.statusCode != 200) {
//         throw Exception("Vision API Error: ${visionResponse.body}");
//       }

//       final visionData = jsonDecode(visionResponse.body);
//       final fullText =
//           visionData['responses'][0]['textAnnotations'][0]['description'];

//       // Process the extracted text with Vertex AI
//       final prompt = [
//         Content.text(
//           """Extract events and their dates from this text: $fullText
//           Return the response as a valid JSON object with exactly this structure:
//           {
//             "events": [
//               {
//                 "event": "Event Name",
//                 "start_date": "DD Month YYYY",
//                 "end_date": "DD Month YYYY"
//               }
//             ]
//           }
//           Include all events you can find with their dates.
//           Use the exact JSON format specified above.""",
//         ),
//       ];

//       final response = await model.generateContent(prompt);
//       final vertexResponse = response.text ?? "{}";

//       // Parse the Vertex AI response
//       final parsedEvents = _parseVertexAIResponse(vertexResponse);

//       // Save and update state
//       await _saveToJsonFile(parsedEvents);
//       await _saveToFirestore(parsedEvents);

//       setState(() {
//         _extractedText = fullText;
//         _vertexAIResponse = vertexResponse;
//         _events = parsedEvents;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _extractedText = "Error: $e";
//         _vertexAIResponse = "Error processing with Vertex AI: $e";
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Text & Event Extractor")),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton(
//                   onPressed: () => _pickImage(ImageSource.camera),
//                   child: Text("Take Photo"),
//                 ),
//                 ElevatedButton(
//                   onPressed: () => _pickImage(ImageSource.gallery),
//                   child: Text("Pick from Gallery"),
//                 ),
//               ],
//             ),
//             SizedBox(height: 20),
//             if (_image != null)
//               Image.file(_image!, height: 200, fit: BoxFit.contain),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _extractTextAndEvents,
//               child: _isLoading
//                   ? CircularProgressIndicator(color: Colors.white)
//                   : Text("Extract Text & Events"),
//             ),
//             SizedBox(height: 20),
//             if (_extractedText.isNotEmpty)
//               Card(
//                 child: Padding(
//                   padding: EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Extracted Text:",
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       SizedBox(height: 8),
//                       Text(_extractedText),
//                     ],
//                   ),
//                 ),
//               ),
//             if (_events.isNotEmpty) ...[
//               SizedBox(height: 20),
//               Text(
//                 "Detected Events:",
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//               ),
//               ..._events
//                   .map(
//                     (event) => Card(
//                       margin: EdgeInsets.symmetric(vertical: 8),
//                       child: ListTile(
//                         title: Text(event['event']),
//                         subtitle: Text(
//                           "Start: ${event['start_date']}\n"
//                           "End: ${event['end_date']}",
//                         ),
//                       ),
//                     ),
//                   )
//                   .toList(),
//             ],
//             if (_vertexAIResponse.isNotEmpty)
//               Card(
//                 child: Padding(
//                   padding: EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Vertex AI Analysis:",
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       SizedBox(height: 8),
//                       SelectableText(_vertexAIResponse),
//                     ],
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
