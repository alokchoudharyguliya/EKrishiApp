import 'package:flutter/material.dart';

class EditEventScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  const EditEventScreen({Key? key, required this.event}) : super(key: key);

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late TextEditingController _eventNameController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;

  @override
  void initState() {
    super.initState();
    _eventNameController = TextEditingController(
      text: widget.event['event'] ?? '',
    );
    _startDateController = TextEditingController(
      text: widget.event['start_date'] ?? '',
    );
    _endDateController = TextEditingController(
      text: widget.event['end_date'] ?? '',
    );
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    // Get the current text from the appropriate controller
    final dateString =
        isStartDate ? _startDateController.text : _endDateController.text;

    // Parse the date string into a DateTime object
    DateTime initialDate = DateTime.now();
    if (dateString.isNotEmpty) {
      try {
        final parts = dateString.split('-');
        // print(parts);
        if (parts.length == 3) {
          initialDate = DateTime(
            int.parse(parts[2]), // year
            int.parse(parts[1]), // month
            int.parse(parts[0]), // day
          );
        }
      } catch (e) {
        print('Error parsing date: $e');
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        final formattedDate =
            "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
        if (isStartDate) {
          _startDateController.text = formattedDate;
        } else {
          _endDateController.text = formattedDate;
        }
      });
    }
  }

  void _saveChanges() {
    final updatedEvent = {
      ...widget.event,
      'event': _eventNameController.text,
      'start_date': _startDateController.text,
      'end_date': _endDateController.text,
    };

    Navigator.pop(context, updatedEvent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Event'),
        actions: [IconButton(icon: Icon(Icons.save), onPressed: _saveChanges)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
              controller: _startDateController,
              decoration: InputDecoration(
                labelText: 'Start Date',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, true),
                ),
              ),
              readOnly: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _endDateController,
              decoration: InputDecoration(
                labelText: 'End Date',
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
