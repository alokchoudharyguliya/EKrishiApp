import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HingeAnimation(),
    );
  }
}

// Create a stateful widget
class HingeAnimation extends StatefulWidget {
  @override
  _HingeAnimationState createState() => _HingeAnimationState();
}

class _HingeAnimationState extends State<HingeAnimation>
    with SingleTickerProviderStateMixin {
  // Animation setup
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize the AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );

    // Setup the rotation animation
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.15).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.0,
          0.5,
          curve: Curves.bounceInOut,
        ),
      ),
    );

    // Setup the slide animation
    _slideAnimation = Tween<double>(begin: 100.0, end: 600.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.5,
          1.0,
          curve: Curves.fastOutSlowIn,
        ),
      ),
    );

    // Setup the opacity animation
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.5,
          1.0,
          curve: Curves.fastOutSlowIn,
        ),
      ),
    );
  }

  @override
  void dispose() {
    
    // Dispose the controller when the widget is disposed
    _controller.dispose();
    super.dispose();
  }

  // The animation widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
            backgroundColor: Colors.green[300],
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            title: Text("GeeksForGeeks"),
            centerTitle: true,
      ),
      body: AnimatedBuilder(
            animation: _slideAnimation,
            builder: (BuildContext context, Widget? child) => Container(
              width: 200,
              height: 150,
              padding: EdgeInsets.all(0),
              margin: EdgeInsets.only(
                left: 100,
                top: _slideAnimation.value,
              ),
              child: RotationTransition(
                turns: _rotationAnimation,
                child: Center(
                  child: Text(
                    'GeeksForGeeks',
                    style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(
                                300,
                                150,
                                500,
                            _opacityAnimation.value,
                         ),
                    ),
                  ),
                ),
              ),
            ),
      ),
      
      // The button to trigger the animation
      floatingActionButtonLocation:FloatingActionButtonLocation.miniCenterFloat,
      floatingActionButton: FloatingActionButton(
            child: Icon(Icons.play_arrow),
            backgroundColor: Colors.green[300],
            onPressed: () {
              _controller.forward();
            },
      ),
    );
  }
}