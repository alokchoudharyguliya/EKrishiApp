import 'package:flutter/material.dart';
import 'package:newscalendar/constants/constants.dart';
import '../models/events.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:newscalendar/main.dart';
import 'package:provider/provider.dart';
import 'package:newscalendar/services/auth_service.dart';
import '../services/user_service.dart';

class EditEventScreen extends StatefulWidget {
  final Event? event;
  final bool editing;
  final DateTime? initialStartDate;

  const EditEventScreen({
    Key? key,
    this.event,
    this.editing = false,
    this.initialStartDate,
  }) : super(key: key);

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late TextEditingController _eventNameController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _descriptionController;
  var initialStartDate;

  @override
  void initState() {
    super.initState();
    initialStartDate = widget.event?.startDate ?? widget.initialStartDate;

    _eventNameController = TextEditingController(
      text: widget.event != null ? widget.event!.title : '',
    );
    _startDateController = TextEditingController(
      text:
          widget.event != null
              ? DateFormat('dd-MM-yyyy').format(initialStartDate!)
              : '',
    );
    _endDateController = TextEditingController(
      text:
          widget.event != null && widget.event!.endDate != null
              ? DateFormat('dd-MM-yyyy').format(widget.event!.endDate!)
              : '',
    );
    _descriptionController = TextEditingController(
      text: widget.event != null ? widget.event!.description ?? '' : '',
    );
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime initialDate = DateTime.now();
    final currentDateText =
        isStartDate ? _startDateController.text : _endDateController.text;

    if (currentDateText.isNotEmpty) {
      try {
        initialDate = DateFormat('dd-MM-yyyy').parse(currentDateText);
      } catch (e) {
        print('Error parsing current date: $e');
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final formattedDate = DateFormat('dd-MM-yyyy').format(picked);
      if (isStartDate) {
        _startDateController.text = formattedDate;
      } else {
        _endDateController.text = formattedDate;
      }
    }
  }

  void _saveChanges() async {
    try {
      // Validate required fields
      if (_eventNameController.text.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Event name is required')));
        return;
      }
      final userService = Provider.of<UserService>(context, listen: false);
      final userId = await userService.getUserId();
      print(userId);
      if (userId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('User not authenticated')));
        return;
      }

      final startDate = DateFormat(
        'dd-MM-yyyy',
      ).parse(_startDateController.text);
      print('StartDate ${startDate}');
      // Parse end date only if it's not empty, otherwise use start date
      DateTime endDate;
      if (_endDateController.text.isNotEmpty) {
        endDate = DateFormat('dd-MM-yyyy').parse(_endDateController.text);
        print('EndDate ${DateFormat('dd-MM-yyyy').format(endDate)}');
        if (endDate.isBefore(startDate)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('End date must be after start date')),
          );
          return;
        }
      } else {
        endDate = startDate;
      }

      // Get auth token
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getAuthToken();

      final event =
          widget.editing && widget.event != null
              ? widget.event!.copyWith(
                title: _eventNameController.text,
                startDate: startDate,
                endDate: endDate,
                description: _descriptionController.text,
              )
              : Event(
                lastUpdated: DateTime.now(),
                id: DateTime.now().toString(), // or generate UUID
                title: _eventNameController.text,
                startDate: startDate,
                userId: userId, // Using the actual user ID
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                endDate: endDate,
                description: _descriptionController.text,
              );

      // Show loading indicator
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Saving event...')));

      try {
        // Make HTTP POST request with authorization
        final response = await http.post(
          Uri.parse('$BASE_URL/add-event'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token', // Add auth token
          },
          body: jsonEncode(event.toJson()),
        );

        final responseData = json.decode(response.body);

        if (response.statusCode == 201 || response.statusCode == 200) {
          // Success - return the event
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          Navigator.pop(context, event);
        } else {
          // Handle server error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to save event: ${responseData['message'] ?? 'Unknown error'}',
              ),
            ),
          );
        }
      } catch (e) {
        // Handle network error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error: ${e.toString()}')),
        );
      }
    } on FormatException {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid date format. Please use DD-MM-YYYY')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isStartDateEnabled =
        widget.editing || widget.initialStartDate == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editing ? 'Edit Event' : 'Create Event'),
        actions: [IconButton(icon: Icon(Icons.save), onPressed: _saveChanges)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _eventNameController,
              decoration: InputDecoration(
                labelText: 'Event Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _startDateController,
              decoration: InputDecoration(
                labelText:
                    isStartDateEnabled
                        ? 'Start Date'
                        : DateFormat('dd-MM-yyyy').format(initialStartDate),
                border: OutlineInputBorder(),
                suffixIcon:
                    isStartDateEnabled
                        ? IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context, true),
                        )
                        : null, // No icon when disabled
              ),
              readOnly: true,
              enabled: isStartDateEnabled, // Disable the field when needed
              style: TextStyle(
                color:
                    isStartDateEnabled ? null : Theme.of(context).disabledColor,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _endDateController,
              decoration: InputDecoration(
                labelText: 'End Date (optional)',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, false),
                ),
              ),
              readOnly: true,
            ),
          ],
        ),
      ),
    );
  }
}
