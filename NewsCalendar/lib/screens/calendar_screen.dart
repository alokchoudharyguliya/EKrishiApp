// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:table_calendar/table_calendar.dart';

// class CalendarScreen extends StatefulWidget {
//   @override
//   _CalendarScreenState createState() => _CalendarScreenState();
// }

// class _CalendarScreenState extends State<CalendarScreen> {
//   late final ValueNotifier<List<DateTime>> _selectedEvents;
//   CalendarFormat _calendarFormat = CalendarFormat.month;
//   DateTime _selectedDay = DateTime.now();
//   DateTime _focusedDay = DateTime.now();
//   final GlobalKey _calendarKey = GlobalKey();
//   OverlayEntry? _overlayEntry;
//   AnimationController? _animationController;

//   @override
//   void initState() {
//     super.initState();
//     _selectedEvents = ValueNotifier([]);
//   }

//   @override
//   void dispose() {
//     _selectedEvents.dispose();
//     _removeOverlay();
//     _animationController?.dispose();
//     super.dispose();
//   }

//   void _removeOverlay() {
//     _overlayEntry?.remove();
//     _overlayEntry = null;
//     _animationController?.dispose();
//     _animationController = null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Calendar with Overlay')),
//       body: Center(
//         child: Column(
//           children: [
//             TableCalendar(
//               key: _calendarKey,
//               focusedDay: _focusedDay,
//               selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
//               onDaySelected: (selectedDay, focusedDay) {
//                 setState(() {
//                   _selectedDay = selectedDay;
//                   _focusedDay = focusedDay;
//                 });
//                 _showDayOverlay(selectedDay, context);
//               },
//               onPageChanged: (focusedDay) {
//                 setState(() {
//                   _focusedDay = focusedDay;
//                 });
//               },
//               firstDay: DateTime.utc(2020, 1, 1),
//               lastDay: DateTime.utc(2030, 12, 31),
//               calendarStyle: CalendarStyle(
//                 todayDecoration: BoxDecoration(
//                   color: Colors.blue,
//                   shape: BoxShape.rectangle,
//                 ),
//                 selectedDecoration: BoxDecoration(
//                   color: Colors.blueAccent,
//                   shape: BoxShape.rectangle,
//                 ),
//                 defaultDecoration: BoxDecoration(
//                   color: Colors.transparent,
//                   shape: BoxShape.rectangle,
//                   border: Border.all(color: Colors.black, width: 1),
//                 ),
//                 weekendDecoration: BoxDecoration(
//                   color: Colors.transparent,
//                   shape: BoxShape.rectangle,
//                   border: Border.all(color: Colors.black, width: 1),
//                 ),
//               ),
//               headerStyle: HeaderStyle(
//                 formatButtonVisible: false,
//                 titleCentered: true,
//               ),
//               calendarFormat: _calendarFormat,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showDayOverlay(DateTime selectedDay, BuildContext context) {
//     _removeOverlay(); // Remove any existing overlay

//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: Navigator.of(context),
//     );

//     final screenSize = MediaQuery.of(context).size;

//     _overlayEntry = OverlayEntry(
//       builder: (context) {
//         return Stack(
//           children: [
//             // Semi-transparent background
//             GestureDetector(
//               onTap: _removeOverlay,
//               child: Container(
//                 color: Colors.black.withOpacity(0.3),
//                 width: screenSize.width,
//                 height: screenSize.height,
//               ),
//             ),
//             // Animated overlay content
//             Center(
//               child: ScaleTransition(
//                 scale: CurvedAnimation(
//                   parent: _animationController!,
//                   curve: Curves.easeOutBack,
//                 ),
//                 child: FadeTransition(
//                   opacity: _animationController!,
//                   child: Material(
//                     elevation: 8.0,
//                     borderRadius: BorderRadius.circular(12),
//                     child: Container(
//                       width: screenSize.width * 0.8,
//                       height: screenSize.height * 0.8,
//                       padding: const EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             'Selected Day',
//                             style: TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(height: 20),
//                           Text(
//                             DateFormat.yMMMMd().format(selectedDay),
//                             style: TextStyle(fontSize: 18),
//                           ),
//                           SizedBox(height: 30),
//                           ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: 30,
//                                 vertical: 15,
//                               ),
//                             ),
//                             onPressed: _removeOverlay,
//                             child: Text(
//                               'Close',
//                               style: TextStyle(fontSize: 16),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );

//     Overlay.of(context).insert(_overlayEntry!);
//     _animationController!.forward();
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:table_calendar/table_calendar.dart';

// class FullScreenCalendar extends StatefulWidget {
//   @override
//   _FullScreenCalendarState createState() => _FullScreenCalendarState();
// }

// class _FullScreenCalendarState extends State<FullScreenCalendar> {
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;
//   OverlayEntry? _overlayEntry;
//   AnimationController? _animationController;
//   void _removeOverlay() {
//     _overlayEntry?.remove();
//     _overlayEntry = null;
//     _animationController?.dispose();
//     _animationController = null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final dayBoxHeight =
//         (screenHeight - 150) / 6; // Adjust based on header height

//     return Scaffold(
//       body: TableCalendar(
//         firstDay: DateTime.utc(2000, 1, 1),
//         lastDay: DateTime.utc(2050, 12, 31),
//         focusedDay: _focusedDay,
//         selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
//         onDaySelected: (selectedDay, focusedDay) {
//           setState(() {
//             _selectedDay = selectedDay;
//             _focusedDay = focusedDay;
//           });
//           _showDayOverlay(selectedDay, context);
//         },
//         onPageChanged: (focusedDay) {
//           setState(() {
//             _focusedDay = focusedDay;
//           });
//         },
//         calendarFormat: CalendarFormat.month,
//         // Calendar styling for large boxes
//         calendarStyle: CalendarStyle(
//           // Make the day boxes large and rectangular
//           cellMargin: EdgeInsets.all(2),
//           cellPadding: EdgeInsets.all(8),
//           defaultDecoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: Colors.grey[300]!),
//           ),
//           todayDecoration: BoxDecoration(
//             color: Colors.blue[100],
//             borderRadius: BorderRadius.circular(8),
//           ),
//           selectedDecoration: BoxDecoration(
//             color: Colors.blue,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           weekendDecoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: Colors.grey[300]!),
//           ),
//           outsideDecoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: Colors.grey[200]!),
//           ),
//           // Set fixed height for each day box
//           cellAlignment: Alignment.center,
//         ),
//         // Header styling
//         headerStyle: HeaderStyle(
//           titleCentered: true,
//           formatButtonVisible: false,
//           leftChevronIcon: Icon(Icons.chevron_left, size: 32),
//           rightChevronIcon: Icon(Icons.chevron_right, size: 32),
//           headerPadding: EdgeInsets.symmetric(vertical: 16),
//           titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         // Day styling
//         daysOfWeekStyle: DaysOfWeekStyle(
//           weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
//           weekendStyle: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.red,
//           ),
//         ),
//         // Custom day builder for larger text
//         calendarBuilders: CalendarBuilders(
//           defaultBuilder: (context, day, focusedDay) {
//             return Center(
//               child: Text(day.day.toString(), style: TextStyle(fontSize: 18)),
//             );
//           },
//           todayBuilder: (context, day, focusedDay) {
//             return Center(
//               child: Text(
//                 day.day.toString(),
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             );
//           },
//           selectedBuilder: (context, day, focusedDay) {
//             return Center(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.blue,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Center(
//                   child: Text(
//                     day.day.toString(),
//                     style: TextStyle(fontSize: 18, color: Colors.white),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//         // Weekday labels
//         daysOfWeekHeight: 40,
//         // Row height for each week
//         rowHeight: dayBoxHeight,
//       ),
//     );
//   }

//   void _showDayOverlay(DateTime selectedDay, BuildContext context) {
//     _removeOverlay(); // Remove any existing overlay

//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: Navigator.of(context),
//     );

//     final screenSize = MediaQuery.of(context).size;

//     _overlayEntry = OverlayEntry(
//       builder: (context) {
//         return Stack(
//           children: [
//             // Semi-transparent background
//             GestureDetector(
//               onTap: _removeOverlay,
//               child: Container(
//                 color: Colors.black.withOpacity(0.3),
//                 width: screenSize.width,
//                 height: screenSize.height,
//               ),
//             ),
//             // Animated overlay content
//             Center(
//               child: ScaleTransition(
//                 scale: CurvedAnimation(
//                   parent: _animationController!,
//                   curve: Curves.easeOutBack,
//                 ),
//                 child: FadeTransition(
//                   opacity: _animationController!,
//                   child: Material(
//                     elevation: 8.0,
//                     borderRadius: BorderRadius.circular(12),
//                     child: Container(
//                       width: screenSize.width * 0.8,
//                       height: screenSize.height * 0.8,
//                       padding: const EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             'Selected Day',
//                             style: TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(height: 20),
//                           Text(
//                             DateFormat.yMMMMd().format(selectedDay),
//                             style: TextStyle(fontSize: 18),
//                           ),
//                           SizedBox(height: 30),
//                           ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: 30,
//                                 vertical: 15,
//                               ),
//                             ),
//                             onPressed: _removeOverlay,
//                             child: Text(
//                               'Close',
//                               style: TextStyle(fontSize: 16),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );

//     Overlay.of(context).insert(_overlayEntry!);
//     _animationController!.forward();
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:table_calendar/table_calendar.dart';

// class FullScreenCalendar extends StatefulWidget {
//   @override
//   _FullScreenCalendarState createState() => _FullScreenCalendarState();
// }

// class _FullScreenCalendarState extends State<FullScreenCalendar> {
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final dayBoxHeight =
//         (screenHeight - 150) / 6; // Adjust based on header height

//     return Scaffold(
//       body: TableCalendar(
//         firstDay: DateTime.utc(2000, 1, 1),
//         lastDay: DateTime.utc(2050, 12, 31),
//         focusedDay: _focusedDay,
//         selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
//         onDaySelected: (selectedDay, focusedDay) {
//           setState(() {
//             _selectedDay = selectedDay;
//             _focusedDay = focusedDay;
//           });
//           _showDayBottomSheet(selectedDay, context);
//         },
//         onPageChanged: (focusedDay) {
//           setState(() {
//             _focusedDay = focusedDay;
//           });
//         },
//         calendarFormat: CalendarFormat.month,
//         calendarStyle: CalendarStyle(
//           cellMargin: EdgeInsets.all(2),
//           cellPadding: EdgeInsets.all(8),
//           defaultDecoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: Colors.grey[300]!),
//           ),
//           todayDecoration: BoxDecoration(
//             color: Colors.blue[100],
//             borderRadius: BorderRadius.circular(8),
//           ),
//           selectedDecoration: BoxDecoration(
//             color: Colors.blue,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           weekendDecoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: Colors.grey[300]!),
//           ),
//           outsideDecoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: Colors.grey[200]!),
//           ),
//           cellAlignment: Alignment.center,
//         ),
//         headerStyle: HeaderStyle(
//           titleCentered: true,
//           formatButtonVisible: false,
//           leftChevronIcon: Icon(Icons.chevron_left, size: 32),
//           rightChevronIcon: Icon(Icons.chevron_right, size: 32),
//           headerPadding: EdgeInsets.symmetric(vertical: 16),
//           titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         daysOfWeekStyle: DaysOfWeekStyle(
//           weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
//           weekendStyle: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.red,
//           ),
//         ),
//         calendarBuilders: CalendarBuilders(
//           defaultBuilder: (context, day, focusedDay) {
//             return Center(
//               child: Text(day.day.toString(), style: TextStyle(fontSize: 18)),
//             );
//           },
//           todayBuilder: (context, day, focusedDay) {
//             return Center(
//               child: Text(
//                 day.day.toString(),
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             );
//           },
//           selectedBuilder: (context, day, focusedDay) {
//             return Center(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.blue,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Center(
//                   child: Text(
//                     day.day.toString(),
//                     style: TextStyle(fontSize: 18, color: Colors.white),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//         daysOfWeekHeight: 40,
//         rowHeight: dayBoxHeight,
//       ),
//     );
//   }

//   void _showDayBottomSheet(DateTime selectedDay, BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Container(
//           padding: EdgeInsets.all(20),
//           height: MediaQuery.of(context).size.height * 0.8,
//           width: MediaQuery.of(context).size.width * 0.9,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'Selected Day',
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 20),
//               Text(
//                 DateFormat.yMMMMd().format(selectedDay),
//                 style: TextStyle(fontSize: 18),
//               ),
//               SizedBox(height: 30),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//                 ),
//                 onPressed: () => Navigator.pop(context),
//                 child: Text('Close', style: TextStyle(fontSize: 16)),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class FullScreenCalendar extends StatefulWidget {
  @override
  _FullScreenCalendarState createState() => _FullScreenCalendarState();
}

class _FullScreenCalendarState extends State<FullScreenCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  OverlayEntry? _overlayEntry;
  AnimationController? _animationController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  List<DateTime> _eventDates = [];

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  // Future<void> _fetchEvents() async {
  //   try {
  //     final querySnapshot = await _firestore.collection('events').get();
  //     final events = <DateTime, List<Map<String, dynamic>>>{};
  //     final eventDates = <DateTime>[];

  //     for (var doc in querySnapshot.docs) {
  //       final eventData = doc.data();
  //       final eventDate = (eventData['start_date'] as Timestamp).toDate();
  //       final dateWithoutTime = DateTime(
  //         eventDate.year,
  //         eventDate.month,
  //         eventDate.day,
  //       );

  //       if (!events.containsKey(dateWithoutTime)) {
  //         events[dateWithoutTime] = [];
  //         eventDates.add(dateWithoutTime);
  //       }
  //       events[dateWithoutTime]!.add(eventData);
  //     }

  //     setState(() {
  //       _events = events;
  //       _eventDates = eventDates;
  //     });
  //   } catch (e) {
  //     print('Error fetching events: $e');
  //   }
  // }
  Future<void> _fetchEvents() async {
    try {
      final querySnapshot = await _firestore.collection('events').get();
      final events = <DateTime, List<Map<String, dynamic>>>{};
      final eventDates = <DateTime>[];

      for (var doc in querySnapshot.docs) {
        final eventData = doc.data();
        // print(eventData['start_date']);
        final dateString =
            eventData['start_date'] as String; // Get date as string

        // Parse the string to DateTime
        DateTime? eventDate;
        try {
          eventDate = DateFormat('dd-MM-yyyy').parse(dateString);
        } catch (e) {
          print('Error parsing date $dateString: $e');
          continue; // Skip this event if date parsing fails
        }

        final dateWithoutTime = DateTime(
          eventDate.year,
          eventDate.month,
          eventDate.day,
        );
        print(eventDate.year);
        if (!events.containsKey(dateWithoutTime)) {
          events[dateWithoutTime] = [];
          eventDates.add(dateWithoutTime);
        }
        events[dateWithoutTime]!.add(eventData);
        print(events.toString());
        print(_events.toString());
      }

      setState(() {
        _events = events;
        _eventDates = eventDates;
      });
      print(_events.toString());
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _animationController?.dispose();
    _animationController = null;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final dayBoxHeight = (screenHeight - 150) / 6;

    return Scaffold(
      body: TableCalendar(
        firstDay: DateTime.utc(2000, 1, 1),
        lastDay: DateTime.utc(2050, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          _showDayOverlay(selectedDay, context);
        },
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
        },
        calendarFormat: CalendarFormat.month,
        eventLoader: (day) {
          final dateWithoutTime = DateTime(day.year, day.month, day.day);
          return _events[dateWithoutTime] ?? [];
        },
        calendarStyle: CalendarStyle(
          markersMaxCount: 1,
          markerDecoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
          markersAlignment: Alignment.bottomCenter,
          markersOffset: PositionedOffset(bottom: 2),
          cellMargin: EdgeInsets.all(2),
          cellPadding: EdgeInsets.all(8),
          defaultDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          todayDecoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(8),
          ),
          selectedDecoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          weekendDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          outsideDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          cellAlignment: Alignment.center,
        ),
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          leftChevronIcon: Icon(Icons.chevron_left, size: 32),
          rightChevronIcon: Icon(Icons.chevron_right, size: 32),
          headerPadding: EdgeInsets.symmetric(vertical: 16),
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
          weekendStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            return Center(
              child: Text(day.day.toString(), style: TextStyle(fontSize: 18)),
            );
          },
          todayBuilder: (context, day, focusedDay) {
            return Center(
              child: Text(
                day.day.toString(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          },
          selectedBuilder: (context, day, focusedDay) {
            return Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    day.day.toString(),
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            );
          },
        ),
        daysOfWeekHeight: 40,
        rowHeight: dayBoxHeight,
      ),
    );
  }

  void _showDayOverlay(DateTime selectedDay, BuildContext context) async {
    _removeOverlay();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: Navigator.of(context),
    );

    final screenSize = MediaQuery.of(context).size;
    final dateWithoutTime = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
    );
    final dayEvents = _events[dateWithoutTime] ?? [];
    print(_events.toString());
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            GestureDetector(
              onTap: _removeOverlay,
              child: Container(
                color: Colors.black.withOpacity(0.3),
                width: screenSize.width,
                height: screenSize.height,
              ),
            ),
            Center(
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: _animationController!,
                  curve: Curves.easeOutBack,
                ),
                child: FadeTransition(
                  opacity: _animationController!,
                  child: Material(
                    elevation: 8.0,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: screenSize.width * 0.8,
                      height: screenSize.height * 0.8,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Selected Day',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            DateFormat.yMMMMd().format(selectedDay),
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 30, child: Text("Hey")),
                          if (dayEvents.isNotEmpty) ...[
                            Text(
                              'Events:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Expanded(
                              child: ListView.builder(
                                itemCount: dayEvents.length,
                                itemBuilder: (context, index) {
                                  final event = dayEvents[index];
                                  return ListTile(
                                    title: Text(event['event'] ?? 'No Title'),
                                    subtitle: Text(
                                      event['start_date'] ?? 'No Description',
                                    ),
                                    leading: Icon(
                                      Icons.event,
                                      color: Colors.green,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ] else
                            Text(
                              'No events for this day',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                            ),
                            onPressed: _removeOverlay,
                            child: Text(
                              'Close',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    _animationController!.forward();
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }
}
