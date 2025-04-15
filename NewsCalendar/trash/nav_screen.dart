import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NavScreen extends StatelessWidget {
  final DateTime selectedDay;

  NavScreen({required this.selectedDay});

  // Function to fetch data from API
  Future<Map<String, dynamic>> fetchData() async {
    final response = await http.get(
      Uri.parse(
        'https://jsonplaceholder.typicode.com/posts/1',
      ), // Replace with your API endpoint
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selected Date')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Selected Date: ${selectedDay.toLocal()}',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            FutureBuilder<Map<String, dynamic>>(
              future: fetchData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Text(
                    'API Data: ${snapshot.data}',
                    style: TextStyle(fontSize: 18),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
