/// Animal Detection Alert Screen
/// 
/// Phase 4 - Animal Detection Implementation
/// Displays detailed information about animal detection alerts
import 'package:flutter/material.dart';

/// Animal Detection Alert Model
class AnimalDetectionAlert {
  final String id;
  final String deviceId;
  final String deviceName;
  final int cameraId;
  final String cameraName;
  final String animalType;
  final double confidence;
  final DateTime timestamp;
  final Map<String, dynamic>? detectionData;
  final String? imageUrl;

  AnimalDetectionAlert({
    required this.id,
    required this.deviceId,
    required this.deviceName,
    required this.cameraId,
    required this.cameraName,
    required this.animalType,
    required this.confidence,
    required this.timestamp,
    this.detectionData,
    this.imageUrl,
  });

  factory AnimalDetectionAlert.fromJson(Map<String, dynamic> json) {
    return AnimalDetectionAlert(
      id: json['_id'] ?? json['id'] ?? '',
      deviceId: json['deviceId'] ?? '',
      deviceName: json['deviceName'] ?? '',
      cameraId: json['cameraId'] ?? 0,
      cameraName: json['cameraName'] ?? 'Camera ${json['cameraId'] ?? 0}',
      animalType: json['animalType'] ?? 'unknown',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      detectionData: json['detection'],
      imageUrl: json['imageUrl'],
    );
  }
}

class AnimalDetectionAlertScreen extends StatefulWidget {
  final AnimalDetectionAlert? initialAlert;

  const AnimalDetectionAlertScreen({
    Key? key,
    this.initialAlert,
  }) : super(key: key);

  @override
  State<AnimalDetectionAlertScreen> createState() =>
      _AnimalDetectionAlertScreenState();
}

class _AnimalDetectionAlertScreenState
    extends State<AnimalDetectionAlertScreen> {
  List<AnimalDetectionAlert> _alerts = [];
  bool _isLoading = true;
  String? _errorMessage;
  AnimalDetectionAlert? _selectedAlert;

  @override
  void initState() {
    super.initState();
    _selectedAlert = widget.initialAlert;
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Replace with actual API endpoint when backend is ready
      // For now, we'll show a placeholder
      // final alerts = await AnimalDetectionService.getAlerts();
      
      setState(() {
        _isLoading = false;
        if (widget.initialAlert != null) {
          _alerts = [widget.initialAlert!];
          _selectedAlert = widget.initialAlert;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load alerts: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animal Detection Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAlerts,
            tooltip: 'Refresh alerts',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _alerts.isEmpty
                  ? _buildEmptyView()
                  : _buildAlertsView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadAlerts,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No alerts',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Animal detection alerts will appear here',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsView() {
    return _selectedAlert != null
        ? _buildAlertDetailView(_selectedAlert!)
        : ListView.builder(
            itemCount: _alerts.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final alert = _alerts[index];
              return _buildAlertCard(alert);
            },
          );
  }

  Widget _buildAlertCard(AnimalDetectionAlert alert) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedAlert = alert;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Animal type icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getAnimalIcon(alert.animalType),
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.animalType.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${alert.deviceName} - ${alert.cameraName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Confidence badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getConfidenceColor(alert.confidence),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(alert.confidence * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatTimestamp(alert.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'View Details →',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertDetailView(AnimalDetectionAlert alert) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          if (_selectedAlert != null)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  _selectedAlert = null;
                });
              },
            ),
          
          // Alert header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getAnimalIcon(alert.animalType),
                          color: Colors.red,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alert.animalType.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${alert.deviceName}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getConfidenceColor(alert.confidence),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${(alert.confidence * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildDetailRow('Camera', alert.cameraName),
                  _buildDetailRow('Device ID', alert.deviceId),
                  _buildDetailRow('Time', _formatTimestamp(alert.timestamp)),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Detection details
          if (alert.detectionData != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detection Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (alert.detectionData!['bbox'] != null)
                      _buildBboxDetails(alert.detectionData!['bbox']),
                  ],
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to camera view
                    Navigator.pop(context);
                    // TODO: Navigate to Farm CCTV widget with this camera selected
                  },
                  icon: const Icon(Icons.videocam),
                  label: const Text('View Camera'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Dismiss alert
                    // TODO: Implement dismiss functionality
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Dismiss'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBboxDetails(Map<String, dynamic> bbox) {
    return Column(
      children: [
        _buildDetailRow('X', bbox['x']?.toString() ?? '0'),
        _buildDetailRow('Y', bbox['y']?.toString() ?? '0'),
        _buildDetailRow('Width', bbox['width']?.toString() ?? '0'),
        _buildDetailRow('Height', bbox['height']?.toString() ?? '0'),
      ],
    );
  }

  IconData _getAnimalIcon(String animalType) {
    switch (animalType.toLowerCase()) {
      case 'dog':
        return Icons.pets;
      case 'cat':
        return Icons.pets;
      case 'cow':
        return Icons.agriculture;
      case 'bird':
        return Icons.air;
      default:
        return Icons.warning;
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) {
      return Colors.red;
    } else if (confidence >= 0.6) {
      return Colors.orange;
    } else {
      return Colors.yellow[700]!;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}

