// import 'package:intl/intl.dart';
// import 'package:flutter/material.dart';
// import 'package:newscalendar/constants/constants.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:web_socket_channel/io.dart';
// import './edit_event_screen.dart';
// import 'package:provider/provider.dart';
// import 'package:newscalendar/main.dart';
// import 'package:newscalendar/auth_service.dart';

// class FullScreenCalendar extends StatefulWidget {
//   @override
//   _FullScreenCalendarState createState() => _FullScreenCalendarState();
// }

// class _FullScreenCalendarState extends State<FullScreenCalendar> {
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;
//   OverlayEntry? _overlayEntry;
//   AnimationController? _animationController;
//   Map<String, List<Map<String, dynamic>>> _events = {};
//   List<String> _eventIds = []; // Changed to store event IDs instead of dates
//   final String apiBaseUrl = '$SOCK_BASE_URL';
//   WebSocketChannel? _channel;
//   String? _currentUserId;
//   List<String> _userEventIds = [];

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentUser();
//     _connectToWebSocket();
//   }

//   Future<void> _getCurrentUser() async {
//     final authService = Provider.of<AuthService>(context, listen: false);
//     final userService = Provider.of<UserService>(context, listen: false);

//     final String? token = authService.token;
//     print(token);

//     try {
//       dynamic userData = await userService.getUserData();
//       if (userData != null && userData['_id'] != null) {
//         print(userData['_id']);
//         setState(() {
//           _currentUserId = userData['_id'];
//           _userEventIds = [userData['_id'], "68016fc81c5bb07e9147133c"];
//         });
//       }
//     } catch (e) {
//       print('Error getting user data: $e');
//     }
//   }

//   void _connectToWebSocket() {
//     try {
//       _channel?.sink.close();
//       _channel = IOWebSocketChannel.connect('$apiBaseUrl/getevents');

//       _channel?.stream.listen(
//         (message) {
//           _processWebSocketMessage(message);
//         },
//         onError: (error) {
//           print('WebSocket error: $error');
//           Future.delayed(Duration(seconds: 5), _connectToWebSocket);
//         },
//         onDone: () {
//           print('WebSocket connection closed');
//           Future.delayed(Duration(seconds: 5), _connectToWebSocket);
//         },
//       );
//     } catch (e) {
//       print('Error connecting to WebSocket: $e');
//       Future.delayed(Duration(seconds: 5), _connectToWebSocket);
//     }
//   }

//   void _processWebSocketMessage(dynamic message) {
//     try {
//       final responseData = json.decode(message);

//       if (responseData["type"] == "events" && responseData["data"] is List) {
//         final events = <String, List<Map<String, dynamic>>>{};
//         final eventIds = <String>[];

//         for (var eventData in responseData["data"]) {
//           try {
//             print(eventData);
//             if (!events.containsKey(eventData['id'])) {
//               events[eventData['id']] = [];
//               eventIds.add(eventData['id']);
//             }
//             events[eventData['id']]!.add(eventData);
//             print(events);
//           } catch (e) {
//             print('Error processing event: $e');
//           }
//         }

//         setState(() {
//           _events = events;
//           _eventIds = eventIds;
//         });
//       }
//     } catch (e) {
//       print('Error processing WebSocket message: $e');
//     }
//   }

//   void _removeOverlay() {
//     _overlayEntry?.remove();
//     _overlayEntry = null;
//     _animationController?.dispose();
//     _animationController = null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final dayBoxHeight = (screenHeight - 150) / 6;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Calendar'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: () {
//               _channel?.sink.add('{"action":"refresh"}');
//             },
//           ),
//         ],
//       ),
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
//         eventLoader: (day) {
//           // Find events that match the selected day
//           final dayEvents =
//               _events.values.expand((eventList) => eventList).where((event) {
//                 try {
//                   final eventDate = DateTime.parse(event['start_date']);
//                   return isSameDay(day, eventDate);
//                 } catch (e) {
//                   return false;
//                 }
//               }).toList();
//           return dayEvents;
//         },
//         calendarStyle: CalendarStyle(
//           markersMaxCount: 1,
//           markerDecoration: BoxDecoration(
//             color: Colors.green,
//             shape: BoxShape.circle,
//           ),
//           markersAlignment: Alignment.bottomCenter,
//           markersOffset: PositionedOffset(bottom: 2),
//           cellMargin: EdgeInsets.all(2),
//           cellPadding: EdgeInsets.all(8),
//           defaultTextStyle: TextStyle(color: Colors.black),
//           weekendTextStyle: TextStyle(color: Colors.red),
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
//             final isEventDay = _events.values
//                 .expand((eventList) => eventList)
//                 .any((event) {
//                   try {
//                     final eventDate = DateTime.parse(event['start_date']);
//                     return isSameDay(eventDate, day);
//                   } catch (e) {
//                     return false;
//                   }
//                 });
//             final isWeekend = _isWeekend(day);
//             final hasUserEvent = _events.values
//                 .expand((eventList) => eventList)
//                 .where((event) {
//                   try {
//                     final eventDate = DateTime.parse(event['start_date']);
//                     return isSameDay(eventDate, day);
//                   } catch (e) {
//                     return false;
//                   }
//                 })
//                 .any((event) => _userEventIds.contains(event['id']));

//             return Center(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color:
//                       hasUserEvent
//                           ? Colors.orange.withOpacity(0.3)
//                           : isEventDay
//                           ? Colors.green.withOpacity(0.2)
//                           : null,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Center(
//                   child: Text(
//                     day.day.toString(),
//                     style: TextStyle(
//                       fontSize: 18,
//                       color:
//                           isWeekend
//                               ? Colors.red
//                               : (hasUserEvent
//                                   ? Colors.orange[800]
//                                   : (isEventDay
//                                       ? Colors.green[800]
//                                       : Colors.black)),
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//           todayBuilder: (context, day, focusedDay) {
//             final isEventDay = _events.values
//                 .expand((eventList) => eventList)
//                 .any((event) {
//                   try {
//                     final eventDate = DateTime.parse(event['start_date']);
//                     return isSameDay(eventDate, day);
//                   } catch (e) {
//                     return false;
//                   }
//                 });
//             final isWeekend = _isWeekend(day);
//             final hasUserEvent = _events.values
//                 .expand((eventList) => eventList)
//                 .where((event) {
//                   try {
//                     final eventDate = DateTime.parse(event['start_date']);
//                     return isSameDay(eventDate, day);
//                   } catch (e) {
//                     return false;
//                   }
//                 })
//                 .any((event) => _userEventIds.contains(event['id']));

//             return Center(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color:
//                       hasUserEvent
//                           ? Colors.orange.withOpacity(0.4)
//                           : (isEventDay
//                               ? Colors.green.withOpacity(0.3)
//                               : Colors.blue[100]),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Center(
//                   child: Text(
//                     day.day.toString(),
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color:
//                           isWeekend
//                               ? Colors.red[700]
//                               : (hasUserEvent
//                                   ? Colors.orange[900]
//                                   : (isEventDay
//                                       ? Colors.green[900]
//                                       : Colors.black)),
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//           selectedBuilder: (context, day, focusedDay) {
//             final isEventDay = _events.values
//                 .expand((eventList) => eventList)
//                 .any((event) {
//                   try {
//                     final eventDate = DateTime.parse(event['start_date']);
//                     return isSameDay(eventDate, day);
//                   } catch (e) {
//                     return false;
//                   }
//                 });
//             final hasUserEvent = _events.values
//                 .expand((eventList) => eventList)
//                 .where((event) {
//                   try {
//                     final eventDate = DateTime.parse(event['start_date']);
//                     return isSameDay(eventDate, day);
//                   } catch (e) {
//                     return false;
//                   }
//                 })
//                 .any((event) => _userEventIds.contains(event['id']));

//             return Center(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color:
//                       hasUserEvent
//                           ? Colors.orange
//                           : (isEventDay ? Colors.green : Colors.blue),
//                   shape: BoxShape.circle,
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
//           outsideBuilder: (context, day, focusedDay) {
//             final isEventDay = _events.values
//                 .expand((eventList) => eventList)
//                 .any((event) {
//                   try {
//                     final eventDate = DateTime.parse(event['start_date']);
//                     return isSameDay(eventDate, day);
//                   } catch (e) {
//                     return false;
//                   }
//                 });
//             final isWeekend = _isWeekend(day);
//             final hasUserEvent = _events.values
//                 .expand((eventList) => eventList)
//                 .where((event) {
//                   try {
//                     final eventDate = DateTime.parse(event['start_date']);
//                     return isSameDay(eventDate, day);
//                   } catch (e) {
//                     return false;
//                   }
//                 })
//                 .any((event) => _userEventIds.contains(event['id']));

//             return Center(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color:
//                       hasUserEvent
//                           ? Colors.orange.withOpacity(0.1)
//                           : (isEventDay ? Colors.green.withOpacity(0.1) : null),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Center(
//                   child: Text(
//                     day.day.toString(),
//                     style: TextStyle(
//                       fontSize: 18,
//                       color:
//                           isWeekend
//                               ? Colors.red[300]
//                               : (hasUserEvent
//                                   ? Colors.orange[400]
//                                   : (isEventDay
//                                       ? Colors.green[400]
//                                       : Colors.grey[400])),
//                     ),
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

//   bool _isWeekend(DateTime day) {
//     return day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
//   }

//   void _showDayOverlay(DateTime selectedDay, BuildContext context) {
//     _removeOverlay();

//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: Navigator.of(context),
//     );

//     final screenSize = MediaQuery.of(context).size;
//     final dayEvents =
//         _events.values.expand((eventList) => eventList).where((event) {
//           try {
//             final eventDate = DateTime.parse(event['start_date']);
//             return isSameDay(eventDate, selectedDay);
//           } catch (e) {
//             return false;
//           }
//         }).toList();

//     _overlayEntry = OverlayEntry(
//       builder: (context) {
//         return Stack(
//           children: [
//             GestureDetector(
//               onTap: _removeOverlay,
//               child: Container(
//                 color: Colors.black.withOpacity(0.3),
//                 width: screenSize.width,
//                 height: screenSize.height,
//               ),
//             ),
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
//                           SizedBox(height: 30, child: Text("Hey")),
//                           if (dayEvents.isNotEmpty) ...[
//                             Text(
//                               'Events:',
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(height: 10),
//                             Expanded(
//                               child: ListView.builder(
//                                 itemCount: dayEvents.length,
//                                 itemBuilder: (context, index) {
//                                   final event = dayEvents[index];
//                                   return ListTile(
//                                     leading: SizedBox(
//                                       width: 30,
//                                       child: TextButton(
//                                         child: Icon(
//                                           Icons.edit,
//                                           color: Colors.blue,
//                                         ),
//                                         onPressed: () {
//                                           _removeOverlay();
//                                           Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder:
//                                                   (context) => EditEventScreen(
//                                                     editing: true,
//                                                     initialStartDate:
//                                                         selectedDay,
//                                                   ),
//                                             ),
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                     title: Container(
//                                       width: double.infinity,
//                                       child: Text(event['event'] ?? 'No Title'),
//                                     ),
//                                     subtitle: Container(
//                                       width: double.infinity,
//                                       child: Text(
//                                         event['start_date'] ?? 'No Description',
//                                       ),
//                                     ),
//                                     trailing: SizedBox(
//                                       width: 20,
//                                       child: Icon(
//                                         Icons.event,
//                                         color: Colors.green,
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                           ] else
//                             Text(
//                               'No events for this day',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           SizedBox(height: 20),
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
//                           SizedBox(height: 20),
//                           FloatingActionButton(
//                             onPressed: () {
//                               _removeOverlay();
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder:
//                                       (context) => EditEventScreen(
//                                         editing: false,
//                                         initialStartDate: selectedDay,
//                                       ),
//                                 ),
//                               );
//                             },
//                             child: Icon(Icons.add),
//                             tooltip: "Add Event Manually",
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

//   @override
//   void dispose() {
//     _channel?.sink.close();
//     _removeOverlay();
//     super.dispose();
//   }
// }
