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

  // Future<void> _saveToFirestore(List<Map<String, dynamic>> events) async {
  //   // if (!_isFirebaseInitialized) {
  //   //   print('Firebase not initialized');
  //   //   return;
  //   // }

  //   try {
  //     final collectionRef = _firestore.collection('events');
  //     final batch = _firestore.batch();

  //     for (var event in events) {
  //       final docRef = collectionRef.doc();
  //       batch.set(docRef, {
  //         'event': event['event'],
  //         'start_date': event['start_date'],
  //         'end_date': event['end_date'],
  //       });
  //     }

  //     await batch.commit();
  //     print('Events saved to Firestore');
  //   } catch (e) {
  //     print('Error saving to Firestore: $e');
  //   }
  //   // const String apiUrl =
  //   //     'https://your-api-endpoint.com/events'; // Replace with your API URL
  //   // try {
  //   //   final response = await http.post(
  //   //     Uri.parse(apiUrl),
  //   //     headers: {
  //   //       'Content-Type': 'application/json', // Required for JSON data
  //   //     },
  //   //     body: jsonEncode({
  //   //       'events': events, // Same structure as your JSON file logic
  //   //       'createdAt':
  //   //           DateTime.now().toIso8601String(), // Optional: Add timestamp
  //   //     }),
  //   //   );

  //   //   if (response.statusCode == 200) {
  //   //     print('Success! Data sent to server.');
  //   //     print('Response: ${response.body}');
  //   //   } else {
  //   //     print('Error: ${response.statusCode}');
  //   //     print('Response: ${response.body}');
  //   //   }
  //   // } catch (e) {
  //   //   print('Failed to send data: $e');
  //   // }
  // }
