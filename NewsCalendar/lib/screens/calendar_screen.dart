import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:newscalendar/constants/constants.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

import 'package:newscalendar/main.dart';
import 'package:newscalendar/auth_service.dart';
import '../color/color.dart';
import 'update_event_screen.dart';
import 'create_event_screen.dart';

class FullScreenCalendar extends StatefulWidget {
  @override
  _FullScreenCalendarState createState() => _FullScreenCalendarState();
}

class _FullScreenCalendarState extends State<FullScreenCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  OverlayEntry? _overlayEntry;
  AnimationController? _animationController;
  Map<String, List<Map<String, dynamic>>> _events = {};
  List<String> _eventIds = []; // Changed to store event IDs instead of dates
  final String apiBaseUrl = '$SOCK_BASE_URL';
  WebSocketChannel? _channel;
  String? _currentUserId;
  String _newEventTitle = '';
  String _newEventDescription = '';
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _connectToWebSocket();
    _focusNode.canRequestFocus = false;
  }

  Future<void> _getCurrentUser() async {
    // final authService = Provider.of<AuthService>(context, listen: false);
    final userService = Provider.of<UserService>(context, listen: false);

    try {
      dynamic userData = await userService.getUserData();
      if (userData != null && userData['_id'] != null) {
        setState(() {
          _currentUserId = userData['_id'];
        });
      }
    } catch (e) {
      // print('Error getting user data: $e');
    }
  }

  Future<void> _updateEventViaWebSocket(
    Map<String, dynamic> updates,
    String eventId,
  ) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;

    if (_channel == null || token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Not connected or not authenticated'),
          duration: Duration(milliseconds: 90),
        ),
      );
      return;
    }

    try {
      final message = json.encode({
        "action": "updateEvent",
        "eventId": eventId,
        "updates":
            updates, // Changed from "event" to "updates" to match backend
        "token": token,
      });

      _channel!.sink.add(message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Updating event...'),
          duration: Duration(milliseconds: 90),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update event: $e'),
          duration: Duration(milliseconds: 90),
        ),
      );
    }
  }

  Future<void> _createEventViaWebSocket(Map<String, dynamic> eventData) async {
    print(eventData);
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;
    print("This is create))))))))");
    if (_channel == null || token == null) {
      print("This )");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Not connected or not authenticated'),
          duration: Duration(milliseconds: 90),
        ),
      );
      return;
    }
    try {
      print("${eventData}");
      final message = json.encode({
        "action": "createEvent",
        "event": eventData,
        "token": token, // Include the token for authentication
      });
      print(token);
      _channel!.sink.add(message);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Creating event...'),
          duration: Duration(milliseconds: 90),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create event: $e'),
          duration: Duration(milliseconds: 90),
        ),
      );
    }
  }

  // Modify the _connectToWebSocket method to handle event creation responses
  void _connectToWebSocket() {
    try {
      _getCurrentUser();
      _channel?.sink.close();
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = authService.token;
      _channel = IOWebSocketChannel.connect(
        '$apiBaseUrl?token=$token',
        headers: {'Authorization': 'Bearer $token'},
      );

      _channel?.stream.listen(
        (message) {
          _processWebSocketMessage(message);
        },
        onError: (error) {
          print('WebSocket error: $error');
          Future.delayed(Duration(seconds: 5), _connectToWebSocket);
        },
        onDone: () {
          print('WebSocket connection closed');
          Future.delayed(Duration(seconds: 5), _connectToWebSocket);
        },
      );
    } catch (e) {
      print('Error connecting to WebSocket: $e');
      Future.delayed(Duration(seconds: 5), _connectToWebSocket);
    }
  }

  void _processWebSocketMessage(dynamic message) {
    try {
      final responseData = json.decode(message);
      print('WebSocket message: $responseData');

      if (responseData["type"] == "events") {
        // Handle events list update
        final events = <String, List<Map<String, dynamic>>>{};
        final eventIds = <String>[];

        for (var eventData in responseData["data"]) {
          if (!events.containsKey(eventData['id'])) {
            events[eventData['id']] = [];
            eventIds.add(eventData['id']);
          }
          events[eventData['id']]!.add(eventData);
        }

        setState(() {
          _events = events;
          _eventIds = eventIds;
        });
      } else if (responseData["type"] == "eventCreated") {
        // Handle successful event creation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Event created successfully'),
            duration: Duration(milliseconds: 90),
          ),
        );
        // Refresh events to include the newly created one
        _channel?.sink.add('{"action":"refresh"}');
      } else if (responseData["type"] == "eventUpdated") {
        // Handle successful event update
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Event updated successfully'),
            duration: Duration(milliseconds: 90),
          ),
        );

        // If the response contains the updated event, update local state
        if (responseData["event"] != null) {
          final updatedEvent = responseData["event"];
          setState(() {
            if (_events.containsKey(updatedEvent["id"])) {
              // Replace the existing event with the updated one
              _events[updatedEvent["id"]] = [updatedEvent];
            }
          });
        } else {
          // If no event data in response, refresh the entire list
          _channel?.sink.add('{"action":"refresh"}');
        }
      } else if (responseData["type"] == "error") {
        // Handle errors with more detailed message from backend
        String errorMessage = 'Error occurred';
        if (responseData["message"] != null) {
          errorMessage = responseData["message"];
        } else if (responseData["error"] != null) {
          errorMessage = responseData["error"];
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: Duration(milliseconds: 50),
          ),
        );
      }
    } catch (e) {
      // print('Error processing WebSocket message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing server message'),
          duration: Duration(milliseconds: 90),
        ),
      );
    }
  }

  Future<void> _deleteEventViaWebSocket(String eventId) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;
    print(token);
    print(_channel);
    if (_channel == null || token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Not connected or not authenticated'),
          duration: Duration(milliseconds: 90),
        ),
      );
      return;
    }

    try {
      final message = json.encode({
        "action": "deleteEvent",
        "eventId": eventId,
        "token": token,
      });

      _channel!.sink.add(message);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleting event...'),
          duration: Duration(milliseconds: 90),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete event: $e'),
          duration: Duration(milliseconds: 90),
        ),
      );
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
    final dayBoxHeight = (screenHeight - 150) / 7;
    final calendarColors = Theme.of(context).extension<CalendarColors>()!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _channel?.sink.add('{"action":"refresh"}');
            },
          ),
        ],
      ),
      body: TableCalendar(
        firstDay: DateTime.utc(2000, 1, 1),
        availableCalendarFormats: const {CalendarFormat.month: 'Month'},
        sixWeekMonthsEnforced: true,
        lastDay: DateTime.utc(2050, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          if (selectedDay.month != _focusedDay.month) {
            return;
          }
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
          final dayEvents =
              _events.values.expand((eventList) => eventList).where((event) {
                try {
                  final eventDate = DateTime.parse(event['start_date']);
                  return isSameDay(day, eventDate);
                } catch (e) {
                  return false;
                }
              }).toList();
          return dayEvents;
        },
        calendarStyle: CalendarStyle(
          markersMaxCount: 1,
          markerDecoration: BoxDecoration(
            color: calendarColors.otherUserFont,
            shape: BoxShape.circle,
          ),
          markersAlignment: Alignment.bottomCenter,
          markersOffset: PositionedOffset(bottom: 2),
          cellMargin: EdgeInsets.all(2),
          cellPadding: EdgeInsets.all(4),
          defaultTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          weekendTextStyle: TextStyle(
            color: isDarkMode ? Colors.red[200] : Colors.red,
          ),
          defaultDecoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
            ),
          ),
          todayDecoration: BoxDecoration(
            color: calendarColors.todayEventBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          selectedDecoration: BoxDecoration(
            color: calendarColors.selectedEventBackground,
            shape: BoxShape.circle,
          ),
          weekendDecoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
            ),
          ),
          outsideTextStyle: TextStyle(color: calendarColors.differentMonthFont),
          outsideDecoration: BoxDecoration(
            shape: BoxShape.circle,
            color: calendarColors.differentMonthBackground,
          ),
          cellAlignment: Alignment.center,
        ),
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: Colors.white,
            size: 32,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: Colors.white,
            size: 32,
          ),
          headerPadding: EdgeInsets.symmetric(vertical: 8),
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          weekendStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.red[200] : Colors.red,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            final isDifferentMonth = day.month != focusedDay.month;
            if (isDifferentMonth) {
              return _buildDifferentMonthDay(day, calendarColors);
            }

            final isEventDay = _events.values
                .expand((eventList) => eventList)
                .any((event) {
                  try {
                    final eventDate = DateTime.parse(event['start_date']);
                    return isSameDay(eventDate, day);
                  } catch (e) {
                    return false;
                  }
                });

            final isWeekend = _isWeekend(day);
            final hasUserEvent = _events.values
                .expand((eventList) => eventList)
                .where((event) {
                  try {
                    final eventDate = DateTime.parse(event['start_date']);
                    return isSameDay(eventDate, day);
                  } catch (e) {
                    return false;
                  }
                })
                .any((event) => event['userId'] == _currentUserId);

            return Center(
              child: Container(
                decoration: BoxDecoration(
                  color:
                      hasUserEvent
                          ? calendarColors.userBackground
                          : (isEventDay
                              ? calendarColors.otherUserBackground
                              : null),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    day.day.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      color:
                          isWeekend
                              ? (isDarkMode ? Colors.red[200] : Colors.red)
                              : (hasUserEvent
                                  ? calendarColors.userFont
                                  : (isEventDay
                                      ? calendarColors.otherUserFont
                                      : Theme.of(
                                        context,
                                      ).colorScheme.onSurface)),
                    ),
                  ),
                ),
              ),
            );
          },
          todayBuilder: (context, day, focusedDay) {
            final isDifferentMonth = day.month != focusedDay.month;
            if (isDifferentMonth) {
              return _buildDifferentMonthDay(day, calendarColors);
            }

            final isEventDay = _events.values
                .expand((eventList) => eventList)
                .any((event) {
                  try {
                    final eventDate = DateTime.parse(event['start_date']);
                    return isSameDay(eventDate, day);
                  } catch (e) {
                    return false;
                  }
                });

            final isWeekend = _isWeekend(day);
            final hasUserEvent = _events.values
                .expand((eventList) => eventList)
                .where((event) {
                  try {
                    final eventDate = DateTime.parse(event['start_date']);
                    return isSameDay(eventDate, day);
                  } catch (e) {
                    return false;
                  }
                })
                .any((event) => event['userId'] == _currentUserId);

            return Center(
              child: Container(
                decoration: BoxDecoration(
                  color:
                      hasUserEvent
                          ? calendarColors.userBackground
                          : (isEventDay
                              ? calendarColors.otherUserBackground
                              : calendarColors.todayEventBackground),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    day.day.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          isWeekend
                              ? (isDarkMode ? Colors.red[200] : Colors.red)
                              : (hasUserEvent
                                  ? calendarColors.userFont
                                  : (isEventDay
                                      ? calendarColors.otherUserFont
                                      : calendarColors.todayEventFont)),
                    ),
                  ),
                ),
              ),
            );
          },
          selectedBuilder: (context, day, focusedDay) {
            final isDifferentMonth = day.month != focusedDay.month;
            if (isDifferentMonth) {
              return _buildDifferentMonthDay(
                day,
                calendarColors,
                isSelected: true,
              );
            }

            final isEventDay = _events.values
                .expand((eventList) => eventList)
                .any((event) {
                  try {
                    final eventDate = DateTime.parse(event['start_date']);
                    return isSameDay(eventDate, day);
                  } catch (e) {
                    return false;
                  }
                });

            final hasUserEvent = _events.values
                .expand((eventList) => eventList)
                .where((event) {
                  try {
                    final eventDate = DateTime.parse(event['start_date']);
                    return isSameDay(eventDate, day);
                  } catch (e) {
                    return false;
                  }
                })
                .any((event) => event['userId'] == _currentUserId);

            return Center(
              child: Container(
                decoration: BoxDecoration(
                  color:
                      hasUserEvent
                          ? calendarColors.userBackground
                          : (isEventDay
                              ? calendarColors.otherUserBackground
                              : calendarColors.selectedEventBackground),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    day.day.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      color: calendarColors.selectedEventFont,
                    ),
                  ),
                ),
              ),
            );
          },
          outsideBuilder: (context, day, focusedDay) {
            return _buildDifferentMonthDay(day, calendarColors);
          },
        ),
        daysOfWeekHeight: 40,
        rowHeight: dayBoxHeight,
      ),
    );
  }

  Widget _buildDifferentMonthDay(
    DateTime day,
    CalendarColors calendarColors, {
    bool isSelected = false,
  }) {
    final isWeekend = _isWeekend(day);

    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: calendarColors.differentMonthBackground,
        ),
        child: Center(
          child: Text(
            day.day.toString(),
            style: TextStyle(
              fontSize: 18,
              color:
                  isWeekend
                      ? (Theme.of(context).brightness == Brightness.dark
                          ? Colors.red[300]!
                          : Colors.red[300]!)
                      : calendarColors.differentMonthFont,
            ),
          ),
        ),
      ),
    );
  }

  bool _isWeekend(DateTime day) {
    return day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
  }

  void _showDayOverlay(DateTime selectedDay, BuildContext context) {
    _removeOverlay();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: Navigator.of(context),
    );

    final screenSize = MediaQuery.of(context).size;
    final dayEvents =
        _events.values.expand((eventList) => eventList).where((event) {
          try {
            final eventDate = DateTime.parse(event['start_date']);
            return isSameDay(eventDate, selectedDay);
          } catch (e) {
            return false;
          }
        }).toList();

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            GestureDetector(
              onTap: _removeOverlay,
              child: Container(
                color: const Color.fromARGB(28, 0, 0, 0),
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
                        color: Theme.of(context).colorScheme.surface,
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
                                  final isUserEvent =
                                      event['userId'] == _currentUserId;
                                  return ListTile(
                                    leading:
                                        isUserEvent
                                            ? Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SizedBox(
                                                  width: 40, // Increased width
                                                  child: IconButton(
                                                    icon: Icon(
                                                      Icons.edit,
                                                      size:
                                                          24, // Increased size
                                                    ),
                                                    color:
                                                        Theme.of(
                                                          context,
                                                        ).colorScheme.primary,
                                                    onPressed: () {
                                                      _removeOverlay();
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder:
                                                              (
                                                                context,
                                                              ) => UpdateEventScreen(
                                                                event: event,
                                                                updateCallback:
                                                                    _updateEventViaWebSocket,
                                                              ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 40, // Increased width
                                                  child: IconButton(
                                                    icon: Icon(
                                                      Icons.delete,
                                                      size:
                                                          24, // Increased size
                                                      color: Colors.red,
                                                    ),
                                                    onPressed: () {
                                                      _removeOverlay();
                                                      showDialog(
                                                        context: context,
                                                        builder:
                                                            (
                                                              context,
                                                            ) => AlertDialog(
                                                              title: Text(
                                                                'Delete Event',
                                                              ),
                                                              content: Text(
                                                                'Are you sure you want to delete this event?',
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed:
                                                                      () => Navigator.pop(
                                                                        context,
                                                                      ),
                                                                  child: Text(
                                                                    'Cancel',
                                                                  ),
                                                                ),
                                                                ElevatedButton(
                                                                  style: ElevatedButton.styleFrom(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .red,
                                                                  ),
                                                                  onPressed: () {
                                                                    _deleteEventViaWebSocket(
                                                                      event['id'],
                                                                    );
                                                                    Navigator.pop(
                                                                      context,
                                                                    );
                                                                  },
                                                                  child: Text(
                                                                    'Delete',
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            )
                                            : SizedBox(width: 60),
                                    title: Container(
                                      width: double.infinity,
                                      child: Text(
                                        event['title'] ?? 'No Title',
                                        style: TextStyle(
                                          fontSize: 18, // Larger font size
                                          fontWeight: FontWeight.bold, // Bold
                                        ),
                                      ),
                                    ),
                                    subtitle: Container(
                                      width: double.infinity,
                                      child: Text(
                                        event['description'] ??
                                            'No Description',
                                        style: TextStyle(
                                          fontSize: 14, // Smaller font size
                                          color: Colors.grey[600], // Grey color
                                        ),
                                      ),
                                    ),
                                    trailing: SizedBox(
                                      width: 30, // Increased width
                                      child: Icon(
                                        Icons.event,
                                        size: 24, // Increased size
                                        color:
                                            isUserEvent
                                                ? Colors.orange
                                                : Colors.green,
                                      ),
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
                          SizedBox(height: 20),
                          FloatingActionButton(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            onPressed: () {
                              _removeOverlay();
                              final newEvent = {
                                "title": _newEventTitle,
                                "start_date": DateFormat(
                                  "dd-MM-yyyy",
                                ).format(selectedDay),
                                "description": _newEventDescription,
                                "end_date": DateFormat(
                                  "dd-MM-yyyy",
                                ).format(selectedDay),
                              };
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => CreateEventScreen(
                                        event: newEvent,
                                        createCallback:
                                            _createEventViaWebSocket,
                                      ),
                                ),
                              );
                            },
                            child: Icon(Icons.add),
                            tooltip: "Add Event",
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
    // _channel?.sink.close();
    _removeOverlay();
    _animationController?.dispose(); // Add this if not already present
    super.dispose();
  }
}
