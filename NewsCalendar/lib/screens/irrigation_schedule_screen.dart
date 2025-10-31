import 'package:flutter/material.dart';
import 'package:newscalendar/utils/imports.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class IrrigationScheduleScreen extends StatefulWidget {
  final String deviceId;
  final String deviceName;

  const IrrigationScheduleScreen({
    Key? key,
    required this.deviceId,
    required this.deviceName,
  }) : super(key: key);

  @override
  State<IrrigationScheduleScreen> createState() =>
      _IrrigationScheduleScreenState();
}

class _IrrigationScheduleScreenState extends State<IrrigationScheduleScreen> {
  List<Map<String, dynamic>> _schedules = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getAuthToken();

      if (token == null) {
        setState(() {
          _errorMessage = 'Authentication required';
          _isLoading = false;
        });
        return;
      }

      final response = await http
          .get(
            Uri.parse(
              '$BASE_URL/api/irrigation/schedules?deviceId=${widget.deviceId}',
            ),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          setState(() {
            _schedules = List<Map<String, dynamic>>.from(
              data['data']['schedules'] ?? [],
            );
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Failed to fetch schedules';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch schedules';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching schedules: $e');
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteSchedule(String scheduleId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Schedule'),
            content: const Text(
              'Are you sure you want to delete this schedule?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getAuthToken();

      if (token == null) return;

      final response = await http
          .delete(
            Uri.parse('$BASE_URL/api/irrigation/schedule/$scheduleId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Schedule deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchSchedules();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete schedule'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleSchedule(String scheduleId, bool currentEnabled) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getAuthToken();

      if (token == null) return;

      final response = await http
          .post(
            Uri.parse('$BASE_URL/api/irrigation/schedule/$scheduleId/toggle'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              currentEnabled ? 'Schedule disabled' : 'Schedule enabled',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _fetchSchedules();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatScheduleTime(Map<String, dynamic> schedule) {
    final eventMode = schedule['eventMode'] ?? 'timed';
    final startTime = schedule['startTime'];
    final startDate = schedule['start_date'];

    if (eventMode == 'timed' && startTime != null) {
      try {
        final dateTime = DateTime.parse(startTime);
        final dateFormat = DateFormat('MMM d, yyyy');
        final timeFormat = DateFormat('h:mm a');
        return '${dateFormat.format(dateTime)} at ${timeFormat.format(dateTime)}';
      } catch (e) {
        return 'Invalid date';
      }
    } else if (startDate != null) {
      try {
        final date = DateTime.parse(startDate);
        final dateFormat = DateFormat('MMM d, yyyy');
        return dateFormat.format(date);
      } catch (e) {
        return 'Invalid date';
      }
    }
    return 'No time set';
  }

  String _formatRecurrence(Map<String, dynamic> schedule) {
    final recurrence = schedule['recurrence'];
    if (recurrence == null || recurrence['isRecurring'] != true) {
      return 'One-time';
    }

    final pattern = recurrence['pattern'] ?? 'none';
    switch (pattern) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        final daysOfWeek = recurrence['daysOfWeek'] as List?;
        if (daysOfWeek != null && daysOfWeek.isNotEmpty) {
          final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
          final selectedDays = daysOfWeek.map((d) => dayNames[d]).join(', ');
          return 'Weekly ($selectedDays)';
        }
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      case 'custom':
        final interval = recurrence['interval'] ?? 1;
        return 'Every $interval day(s)';
      default:
        return 'One-time';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Irrigation Schedules - ${widget.deviceName}'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchSchedules,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red[700]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchSchedules,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : _schedules.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.schedule, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No schedules found',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create a new schedule to get started',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _fetchSchedules,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _schedules.length,
                  itemBuilder: (context, index) {
                    final schedule = _schedules[index];
                    final enabled =
                        schedule['irrigationSettings']?['enabled'] ?? true;
                    final isExecuted =
                        schedule['irrigationSettings']?['isExecuted'] ?? false;
                    final duration =
                        schedule['irrigationSettings']?['duration'] ?? 30;
                    final scheduleId = schedule['_id'] ?? schedule['id'];

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Icon(
                          Icons.water_drop,
                          color: enabled ? Colors.blue : Colors.grey,
                          size: 32,
                        ),
                        title: Text(
                          schedule['title'] ?? 'Untitled Schedule',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration:
                                enabled ? null : TextDecoration.lineThrough,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatScheduleTime(schedule),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.repeat,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatRecurrence(schedule),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.timer,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Duration: $duration minutes',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            if (isExecuted) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Executed',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.green[800],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                            if (!enabled) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Disabled',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.orange[800],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                enabled ? Icons.pause : Icons.play_arrow,
                                color: enabled ? Colors.orange : Colors.green,
                              ),
                              onPressed:
                                  () => _toggleSchedule(scheduleId, enabled),
                              tooltip: enabled ? 'Disable' : 'Enable',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteSchedule(scheduleId),
                              tooltip: 'Delete',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => CreateIrrigationScheduleScreen(
                    deviceId: widget.deviceId,
                    deviceName: widget.deviceName,
                  ),
            ),
          ).then((_) => _fetchSchedules());
        },
        icon: const Icon(Icons.add),
        label: const Text('New Schedule'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

// Create Schedule Screen
class CreateIrrigationScheduleScreen extends StatefulWidget {
  final String deviceId;
  final String deviceName;
  final Map<String, dynamic>? existingSchedule;

  const CreateIrrigationScheduleScreen({
    Key? key,
    required this.deviceId,
    required this.deviceName,
    this.existingSchedule,
  }) : super(key: key);

  @override
  State<CreateIrrigationScheduleScreen> createState() =>
      _CreateIrrigationScheduleScreenState();
}

class _CreateIrrigationScheduleScreenState
    extends State<CreateIrrigationScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController(text: '30');

  DateTime? _selectedDateTime;
  String _eventMode = 'timed';
  bool _isRecurring = false;
  String _recurrencePattern = 'daily';
  int _interval = 1;
  List<int> _selectedDaysOfWeek = [];
  DateTime? _recurrenceEndDate;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingSchedule != null) {
      _loadExistingSchedule();
    } else {
      _selectedDateTime = DateTime.now().add(const Duration(hours: 1));
    }
  }

  void _loadExistingSchedule() {
    final schedule = widget.existingSchedule!;
    _titleController.text = schedule['title'] ?? '';
    _descriptionController.text = schedule['description'] ?? '';
    _durationController.text =
        (schedule['irrigationSettings']?['duration'] ?? 30).toString();
    _eventMode = schedule['eventMode'] ?? 'timed';

    if (schedule['startTime'] != null) {
      _selectedDateTime = DateTime.parse(schedule['startTime']);
    } else if (schedule['start_date'] != null) {
      _selectedDateTime = DateTime.parse(schedule['start_date']);
    }

    final recurrence = schedule['recurrence'];
    if (recurrence != null && recurrence['isRecurring'] == true) {
      _isRecurring = true;
      _recurrencePattern = recurrence['pattern'] ?? 'daily';
      _interval = recurrence['interval'] ?? 1;
      _selectedDaysOfWeek = List<int>.from(recurrence['daysOfWeek'] ?? []);
      if (recurrence['endDate'] != null) {
        _recurrenceEndDate = DateTime.parse(recurrence['endDate']);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && _eventMode == 'timed') {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          _selectedDateTime ?? DateTime.now(),
        ),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    } else if (date != null) {
      setState(() {
        _selectedDateTime = date;
      });
    }
  }

  Future<void> _selectRecurrenceEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          _recurrenceEndDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _recurrenceEndDate = date;
      });
    }
  }

  void _toggleDayOfWeek(int day) {
    setState(() {
      if (_selectedDaysOfWeek.contains(day)) {
        _selectedDaysOfWeek.remove(day);
      } else {
        _selectedDaysOfWeek.add(day);
        _selectedDaysOfWeek.sort();
      }
    });
  }

  Future<void> _submitSchedule() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date and time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_isRecurring &&
        _recurrencePattern == 'weekly' &&
        _selectedDaysOfWeek.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one day for weekly schedule'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getAuthToken();

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication required'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isSubmitting = false);
        return;
      }

      final scheduleData = {
        'deviceId': widget.deviceId,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'duration': int.parse(_durationController.text),
        'eventMode': _eventMode,
        'startTime':
            _eventMode == 'timed' ? _selectedDateTime!.toIso8601String() : null,
        'startDate':
            _eventMode == 'all-day'
                ? _selectedDateTime!.toIso8601String()
                : null,
        'recurrence':
            _isRecurring
                ? {
                  'isRecurring': true,
                  'pattern': _recurrencePattern,
                  'interval': _interval,
                  'daysOfWeek':
                      _recurrencePattern == 'weekly' ? _selectedDaysOfWeek : [],
                  'dayOfMonth':
                      _recurrencePattern == 'monthly'
                          ? _selectedDateTime!.day
                          : null,
                  'endDate': _recurrenceEndDate?.toIso8601String(),
                }
                : {'isRecurring': false, 'pattern': 'none'},
      };

      final url =
          widget.existingSchedule != null
              ? '$BASE_URL/api/irrigation/schedule/${widget.existingSchedule!['_id'] ?? widget.existingSchedule!['id']}'
              : '$BASE_URL/api/irrigation/schedule';

      final response =
          widget.existingSchedule != null
              ? await http
                  .put(
                    Uri.parse(url),
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization': 'Bearer $token',
                    },
                    body: json.encode(scheduleData),
                  )
                  .timeout(const Duration(seconds: 15))
              : await http
                  .post(
                    Uri.parse(url),
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization': 'Bearer $token',
                    },
                    body: json.encode(scheduleData),
                  )
                  .timeout(const Duration(seconds: 15));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingSchedule != null
                  ? 'Schedule updated successfully'
                  : 'Schedule created successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to save schedule');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingSchedule != null ? 'Edit Schedule' : 'Create Schedule',
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Schedule Title *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator:
                    (value) =>
                        value?.isEmpty ?? true ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes) *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Duration is required';
                  final duration = int.tryParse(value!);
                  if (duration == null || duration < 1 || duration > 1440) {
                    return 'Duration must be between 1 and 1440 minutes';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _eventMode,
                decoration: const InputDecoration(
                  labelText: 'Event Mode',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.event),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'timed',
                    child: Text('Timed (with specific time)'),
                  ),
                  DropdownMenuItem(value: 'all-day', child: Text('All Day')),
                ],
                onChanged: (value) {
                  setState(() => _eventMode = value!);
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date & Time'),
                subtitle: Text(
                  _selectedDateTime == null
                      ? 'Not selected'
                      : _eventMode == 'timed'
                      ? DateFormat(
                        'MMM d, yyyy h:mm a',
                      ).format(_selectedDateTime!)
                      : DateFormat('MMM d, yyyy').format(_selectedDateTime!),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDateTime,
                tileColor: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Recurring Schedule'),
                subtitle: const Text('Repeat this schedule automatically'),
                value: _isRecurring,
                onChanged: (value) => setState(() => _isRecurring = value),
              ),
              if (_isRecurring) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _recurrencePattern,
                  decoration: const InputDecoration(
                    labelText: 'Repeat Pattern',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.repeat),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'daily', child: Text('Daily')),
                    DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                    DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                    DropdownMenuItem(
                      value: 'custom',
                      child: Text('Custom Interval'),
                    ),
                  ],
                  onChanged:
                      (value) => setState(() => _recurrencePattern = value!),
                ),
                if (_recurrencePattern == 'custom') ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _interval.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Every N days',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_view_day),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _interval = int.tryParse(value) ?? 1;
                    },
                  ),
                ],
                if (_recurrencePattern == 'weekly') ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Select Days:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (int i = 0; i < 7; i++)
                        FilterChip(
                          label: Text(
                            [
                              'Sun',
                              'Mon',
                              'Tue',
                              'Wed',
                              'Thu',
                              'Fri',
                              'Sat',
                            ][i],
                          ),
                          selected: _selectedDaysOfWeek.contains(i),
                          onSelected: (_) => _toggleDayOfWeek(i),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('End Date (Optional)'),
                  subtitle: Text(
                    _recurrenceEndDate == null
                        ? 'No end date'
                        : DateFormat('MMM d, yyyy').format(_recurrenceEndDate!),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _selectRecurrenceEndDate,
                  ),
                  tileColor: Colors.grey[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitSchedule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isSubmitting
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Text(
                          widget.existingSchedule != null
                              ? 'Update Schedule'
                              : 'Create Schedule',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
