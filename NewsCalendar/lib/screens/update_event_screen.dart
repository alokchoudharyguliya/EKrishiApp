import '../models/events.dart' as eventModel;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/network_service.dart';

class UpdateEventScreen extends StatefulWidget {
  final eventModel.Event event;
  final Function(eventModel.Event, String) updateCallback;

  const UpdateEventScreen({
    Key? key,
    required this.event,
    required this.updateCallback,
  }) : super(key: key);

  @override
  _UpdateEventScreenState createState() => _UpdateEventScreenState();
}

class _UpdateEventScreenState extends State<UpdateEventScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _cropTypeController;
  late TextEditingController _cropVarietyController;
  late TextEditingController _fieldLocationController;
  late TextEditingController _equipmentController;
  final FocusScopeNode _focusNode = FocusScopeNode();

  String _eventMode = 'all-day';
  String? _activityType;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  List<String> _equipmentList = [];
  List<Map<String, dynamic>> _reminders = [];

  final List<String> _activityTypes = [
    'Planting',
    'Harvesting',
    'Irrigation',
    'Fertilization',
    'Pest Control',
    'Pruning',
    'Weeding',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController = TextEditingController(
      text: widget.event.description ?? '',
    );

    // Initialize farmer-specific fields
    _cropTypeController = TextEditingController(
      text: widget.event.cropType ?? '',
    );
    _cropVarietyController = TextEditingController(
      text: widget.event.cropVariety ?? '',
    );
    _fieldLocationController = TextEditingController(
      text: widget.event.fieldLocation ?? '',
    );
    _equipmentController = TextEditingController();

    // Initialize event mode and times
    _eventMode = widget.event.eventMode;
    _activityType = widget.event.activityType;
    _equipmentList = List<String>.from(widget.event.equipmentNeeded);

    // Initialize times if timed event
    if (widget.event.eventMode == 'timed' && widget.event.startTime != null) {
      final start = widget.event.startTime!;
      _startTime = TimeOfDay(hour: start.hour, minute: start.minute);
    }
    if (widget.event.eventMode == 'timed' && widget.event.endTime != null) {
      final end = widget.event.endTime!;
      _endTime = TimeOfDay(hour: end.hour, minute: end.minute);
    }

    // Initialize reminders
    _reminders =
        widget.event.reminders.map((r) {
          return {
            'reminderType': r.reminderType,
            'reminderValue': r.reminderValue,
            'reminderTime': r.reminderTime,
          };
        }).toList();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cropTypeController.dispose();
    _cropVarietyController.dispose();
    _fieldLocationController.dispose();
    _equipmentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  void _addEquipment() {
    if (_equipmentController.text.trim().isNotEmpty) {
      setState(() {
        _equipmentList.add(_equipmentController.text.trim());
        _equipmentController.clear();
      });
    }
  }

  void _removeEquipment(int index) {
    setState(() {
      _equipmentList.removeAt(index);
    });
  }

  void _showAddReminderDialog() {
    String reminderType = 'days';
    final TextEditingController valueController = TextEditingController(
      text: '1',
    );

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('Add Reminder'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: reminderType,
                        decoration: const InputDecoration(
                          labelText: 'Reminder Type',
                        ),
                        items: const [
                          DropdownMenuItem(value: 'days', child: Text('Days')),
                          DropdownMenuItem(
                            value: 'hours',
                            child: Text('Hours'),
                          ),
                          DropdownMenuItem(
                            value: 'minutes',
                            child: Text('Minutes'),
                          ),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            reminderType = value ?? 'days';
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: valueController,
                        decoration: const InputDecoration(
                          labelText: 'Value',
                          hintText: 'e.g., 1 for 1 day before',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final value = int.tryParse(valueController.value.text);
                        if (value != null && value > 0) {
                          setState(() {
                            _reminders.add({
                              'reminderType': reminderType,
                              'reminderValue': value,
                            });
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _removeReminder(int index) {
    setState(() {
      _reminders.removeAt(index);
    });
  }

  void _saveChanges() {
    // Check connectivity - WebSocket-only calendar requires online connection
    final isOnline =
        Provider.of<ConnectivityProvider>(context, listen: false).isOnline;
    if (!isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No internet connection. Please connect to the internet to update events.',
          ),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    DateTime startDate = widget.event.startDate;
    DateTime? endDate = widget.event.endDate;

    // Combine date and time for timed events
    // Create DateTime in local timezone - user selected time is local time
    DateTime? startTime;
    DateTime? endTime;

    if (_eventMode == 'timed') {
      if (_startTime != null) {
        // Create local DateTime - this preserves the user's selected time as local
        startTime = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
          _startTime!.hour,
          _startTime!.minute,
        );
      }
      if (_endTime != null) {
        final endDateTime = endDate ?? startDate;
        // Create local DateTime - this preserves the user's selected time as local
        endTime = DateTime(
          endDateTime.year,
          endDateTime.month,
          endDateTime.day,
          _endTime!.hour,
          _endTime!.minute,
        );
      }

      // Validation
      if (startTime == null || endTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please select both start and end times for timed events',
            ),
          ),
        );
        return;
      }

      if (endTime.isBefore(startTime) || endTime.isAtSameMomentAs(startTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End time must be after start time')),
        );
        return;
      }
    }

    // Build reminders array for backend
    List<Map<String, dynamic>> remindersJson = [];
    if (_reminders.isNotEmpty) {
      // Calculate reminder times based on event start
      final eventStartTime = startTime ?? startDate;

      for (var reminder in _reminders) {
        DateTime reminderTime = eventStartTime;

        switch (reminder['reminderType']) {
          case 'days':
            reminderTime = reminderTime.subtract(
              Duration(days: reminder['reminderValue']),
            );
            break;
          case 'hours':
            reminderTime = reminderTime.subtract(
              Duration(hours: reminder['reminderValue']),
            );
            break;
          case 'minutes':
            reminderTime = reminderTime.subtract(
              Duration(minutes: reminder['reminderValue']),
            );
            break;
        }

        remindersJson.add({
          'reminderTime': reminderTime.toIso8601String(),
          'reminderType': reminder['reminderType'],
          'reminderValue': reminder['reminderValue'],
          'isNotified': false,
        });
      }
    }

    final updatedEvent = eventModel.Event.create(
      id: widget.event.id,
      title:
          _titleController.text.isNotEmpty
              ? _titleController.text
              : widget.event.title,
      description:
          _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : widget.event.description,
      startDate: startDate,
      endDate: endDate,
      userId: widget.event.userId,
      changeType: "UPDATE",
      eventMode: _eventMode,
      startTime: startTime,
      endTime: endTime,
      cropType:
          _cropTypeController.text.trim().isNotEmpty
              ? _cropTypeController.text.trim()
              : null,
      cropVariety:
          _cropVarietyController.text.trim().isNotEmpty
              ? _cropVarietyController.text.trim()
              : null,
      activityType: _activityType,
      fieldLocation:
          _fieldLocationController.text.trim().isNotEmpty
              ? _fieldLocationController.text.trim()
              : null,
      equipmentNeeded: _equipmentList,
      reminders:
          remindersJson.map((r) => eventModel.Reminder.fromJson(r)).toList(),
    );

    widget.updateCallback(updatedEvent, widget.event.id);
    Navigator.pop(context);
  }

  Widget _buildReminderChip(int index) {
    final reminder = _reminders[index];
    String label =
        '${reminder['reminderValue']} ${reminder['reminderType']} before';
    if (reminder['reminderValue'] == 1) {
      label = label.replaceAll('s before', ' before');
    }

    return Chip(
      label: Text(label),
      onDeleted: () => _removeReminder(index),
      deleteIcon: const Icon(Icons.close, size: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = context.watch<ConnectivityProvider>().isOnline;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Event'),
        actions: [
          // Connectivity indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(
              isOnline ? Icons.wifi : Icons.wifi_off,
              color: isOnline ? Colors.green : Colors.red,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
            tooltip: isOnline ? 'Save Event' : 'No Internet Connection',
          ),
        ],
      ),
      body: FocusScope(
        node: _focusNode,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                onEditingComplete: () => _focusNode.nextFocus(),
              ),
              const SizedBox(height: 20),

              // Description
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 100,
                  maxHeight: MediaQuery.of(context).size.height * 0.3,
                ),
                child: TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
              const SizedBox(height: 20),

              // Event Mode
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Event Mode',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('All Day'),
                              value: 'all-day',
                              groupValue: _eventMode,
                              onChanged: (value) {
                                setState(() {
                                  _eventMode = value!;
                                  if (_eventMode == 'all-day') {
                                    _startTime = null;
                                    _endTime = null;
                                  }
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Timed'),
                              value: 'timed',
                              groupValue: _eventMode,
                              onChanged: (value) {
                                setState(() {
                                  _eventMode = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      // Time pickers (only for timed events)
                      if (_eventMode == 'timed') ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: _selectStartTime,
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Start Time *',
                                    border: OutlineInputBorder(),
                                    suffixIcon: Icon(Icons.access_time),
                                  ),
                                  child: Text(
                                    _startTime != null
                                        ? _startTime!.format(context)
                                        : 'Select start time',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
                                onTap: _selectEndTime,
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'End Time *',
                                    border: OutlineInputBorder(),
                                    suffixIcon: Icon(Icons.access_time),
                                  ),
                                  child: Text(
                                    _endTime != null
                                        ? _endTime!.format(context)
                                        : 'Select end time',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Farmer-Specific Fields
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Farming Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Activity Type
                      DropdownButtonFormField<String>(
                        value: _activityType,
                        decoration: const InputDecoration(
                          labelText: 'Activity Type',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            _activityTypes.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _activityType = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Crop Type
                      TextField(
                        controller: _cropTypeController,
                        decoration: const InputDecoration(
                          labelText: 'Crop Type',
                          border: OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Crop Variety
                      TextField(
                        controller: _cropVarietyController,
                        decoration: const InputDecoration(
                          labelText: 'Crop Variety',
                          border: OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Field Location
                      TextField(
                        controller: _fieldLocationController,
                        decoration: const InputDecoration(
                          labelText: 'Field/Location',
                          border: OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Equipment Needed
                      TextField(
                        controller: _equipmentController,
                        decoration: InputDecoration(
                          labelText: 'Equipment Needed',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _addEquipment,
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _addEquipment(),
                      ),
                      if (_equipmentList.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(
                            _equipmentList.length,
                            (index) => Chip(
                              label: Text(_equipmentList[index]),
                              onDeleted: () => _removeEquipment(index),
                              deleteIcon: const Icon(Icons.close, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Reminders Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Reminders',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _showAddReminderDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Reminder'),
                          ),
                        ],
                      ),
                      if (_reminders.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'No reminders added',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(
                            _reminders.length,
                            (index) => _buildReminderChip(index),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
