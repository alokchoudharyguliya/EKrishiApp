import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Entry point of the application
void main() => runApp(MyApp());

// Main application widget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'GeeksForGeeks'),
    );
  }
}

// Home page widget with state
class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

// State class for the home page
class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  // Function to increment the counter
  void _incrementCounter() {
        setState(() {
          _counter++;
        });
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle? display1 = Theme.of(context).textTheme.headlineMedium;
    return Scaffold(
      appBar: AppBar(
            title: Text(widget.title),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                          Text(
                            'You have pushed the button this many times:',
                            style: GoogleFonts.oswald(textStyle: display1),
                          ),
                          Text(
                            '$_counter',
                            style: GoogleFonts.lato(
                                fontStyle: FontStyle.italic,
                                fontSize: 20,
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                ],
              ),
            ),
      ),
      floatingActionButton: FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            child: Icon(Icons.play_arrow),
      ),
    );
  }
}