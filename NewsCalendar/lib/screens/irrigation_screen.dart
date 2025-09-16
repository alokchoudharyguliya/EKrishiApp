import 'package:flutter/material.dart';

class IrrigationScreen extends StatefulWidget {
  const IrrigationScreen({Key? key}) : super(key: key);

  @override
  State<IrrigationScreen> createState() => _IrrigationScreenState();
}

class _IrrigationScreenState extends State<IrrigationScreen> {
  bool _pumpOn = false;

  // Dummy data for graph (replace with real data as needed)
  final List<Map<String, dynamic>> _pumpTimings = [
    {'day': 'Mon', 'hours': 2},
    {'day': 'Tue', 'hours': 1.5},
    {'day': 'Wed', 'hours': 2.5},
    {'day': 'Thu', 'hours': 1},
    {'day': 'Fri', 'hours': 3},
    {'day': 'Sat', 'hours': 2},
    {'day': 'Sun', 'hours': 1.2},
  ];

  void _togglePump() {
    setState(() {
      _pumpOn = !_pumpOn;
    });
    // Here you can add code to send a request to your backend to switch the pump
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_pumpOn ? 'Pump switched ON' : 'Pump switched OFF'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Irrigation Management'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pump control
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.water,
                      color: _pumpOn ? Colors.blue : Colors.grey,
                      size: 40,
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Text(
                        _pumpOn ? 'Water Pump is ON' : 'Water Pump is OFF',
                        style: TextStyle(
                          fontSize: 18,
                          color: _pumpOn ? Colors.blue : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Switch(
                      value: _pumpOn,
                      onChanged: (val) => _togglePump(),
                      activeColor: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Pump On Timings (hrs/week)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            // Simple bar graph (replace with a chart package for advanced graphs)
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children:
                    _pumpTimings.map((data) {
                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: (data['hours'] as num).toDouble() * 25,
                              width: 18.0,
                              decoration: BoxDecoration(
                                color: Colors.blue[300],
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              data['day'],
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              data['hours'].toString(),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 30),
            // Add more irrigation-related info as needed
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(Icons.info, color: Colors.blue[700]),
                title: const Text('Soil Moisture Sensor'),
                subtitle: const Text('Current: 45% (Optimal: 40-60%)'),
                trailing: Icon(Icons.check_circle, color: Colors.green),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(Icons.schedule, color: Colors.blue[700]),
                title: const Text('Next Scheduled Irrigation'),
                subtitle: const Text('Tomorrow, 6:00 AM'),
                trailing: Icon(Icons.alarm, color: Colors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
