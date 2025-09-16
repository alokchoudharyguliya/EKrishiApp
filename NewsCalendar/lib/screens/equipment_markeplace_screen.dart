import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EquipmentMarketplaceScreen extends StatefulWidget {
  const EquipmentMarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<EquipmentMarketplaceScreen> createState() =>
      _EquipmentMarketplaceScreenState();
}

class _EquipmentMarketplaceScreenState extends State<EquipmentMarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, dynamic>> _myTools = [
    {
      'name': 'Tractor (45HP)',
      'description': 'Available for rent on daily/weekly basis',
      'price': '₹1,500/day',
      'image': 'https://images.unsplash.com/photo-1591638848952-463e8783e1b1',
      'contact': '+91 9876543210',
      'location': 'Lucknow, UP',
      'isAvailable': true,
    },
    {
      'name': 'Rotavator',
      'description': 'Good condition, can be attached to any tractor',
      'price': '₹800/day',
      'image': 'https://images.unsplash.com/photo-1534353436294-0dbd4bdac845',
      'contact': '+91 9876543210',
      'location': 'Lucknow, UP',
      'isAvailable': true,
    },
  ];

  final List<Map<String, dynamic>> _allTools = [
    {
      'name': 'Tractor (45HP)',
      'description': 'Available for rent on daily/weekly basis',
      'price': '₹1,500/day',
      'image': 'https://images.unsplash.com/photo-1591638848952-463e8783e1b1',
      'contact': '+91 9876543210',
      'location': 'Lucknow, UP',
      'ownerName': 'You',
      'isAvailable': true,
    },
    {
      'name': 'Rotavator',
      'description': 'Good condition, can be attached to any tractor',
      'price': '₹800/day',
      'image': 'https://images.unsplash.com/photo-1534353436294-0dbd4bdac845',
      'contact': '+91 9876543210',
      'location': 'Lucknow, UP',
      'ownerName': 'You',
      'isAvailable': true,
    },
    {
      'name': 'Harvester',
      'description': 'Self-propelled harvester for wheat and rice',
      'price': '₹5,000/day',
      'image': 'https://images.unsplash.com/photo-1626437379830-37e95bd7fc80',
      'contact': '+91 9871234560',
      'location': 'Kanpur, UP',
      'ownerName': 'Ramesh Kumar',
      'isAvailable': true,
    },
    {
      'name': 'Water Pump Set',
      'description': '5HP water pump with pipes, diesel operated',
      'price': '₹600/day',
      'image': 'https://images.unsplash.com/photo-1592209535507-cba12d982d29',
      'contact': '+91 9898989898',
      'location': 'Varanasi, UP',
      'ownerName': 'Suresh Patel',
      'isAvailable': true,
    },
    {
      'name': 'Seed Drill',
      'description': '9-row seed drill, suitable for wheat, barley',
      'price': '₹700/day',
      'image': 'https://images.unsplash.com/photo-1560963144-19f6336db4d5',
      'contact': '+91 9856473211',
      'location': 'Allahabad, UP',
      'ownerName': 'Anita Sharma',
      'isAvailable': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _launchCaller(String phone) async {
    final Uri url = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch dialer')),
        );
      }
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    final String phoneNumber = phone.replaceAll('+', '').replaceAll(' ', '');
    final Uri url = Uri.parse('https://wa.me/$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch WhatsApp')),
        );
      }
    }
  }

  void _showAddToolDialog({Map<String, dynamic>? tool}) {
    final nameController = TextEditingController(text: tool?['name'] ?? '');
    final descriptionController = TextEditingController(
      text: tool?['description'] ?? '',
    );
    final priceController = TextEditingController(
      text: tool?['price']?.toString().replaceAll('₹', '') ?? '',
    );
    final contactController = TextEditingController(
      text: tool?['contact'] ?? '',
    );
    final locationController = TextEditingController(
      text: tool?['location'] ?? '',
    );
    final imageController = TextEditingController(text: tool?['image'] ?? '');
    bool isAvailable = tool?['isAvailable'] ?? true;

    final isEditing = tool != null;
    final int? editIndex = isEditing ? _myTools.indexOf(tool) : null;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(isEditing ? 'Edit Tool' : 'Add New Tool'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Tool Name*'),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description*',
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price* (e.g. 1000/day)',
                      prefixText: '₹',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: contactController,
                    decoration: const InputDecoration(
                      labelText: 'Contact Number*',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(labelText: 'Location*'),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: imageController,
                    decoration: const InputDecoration(
                      labelText: 'Image URL (optional)',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('Available for rent:'),
                      const SizedBox(width: 10),
                      Switch(
                        value: isAvailable,
                        onChanged: (value) {
                          isAvailable = !value;
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Validate inputs
                  if (nameController.text.isEmpty ||
                      descriptionController.text.isEmpty ||
                      priceController.text.isEmpty ||
                      contactController.text.isEmpty ||
                      locationController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill all required fields'),
                      ),
                    );
                    return;
                  }

                  // Create tool object
                  final newTool = {
                    'name': nameController.text,
                    'description': descriptionController.text,
                    'price': '₹${priceController.text}',
                    'image':
                        imageController.text.isEmpty
                            ? 'https://images.unsplash.com/photo-1473181488821-2d23949a045a' // default image
                            : imageController.text,
                    'contact': contactController.text,
                    'location': locationController.text,
                    'isAvailable': isAvailable,
                  };

                  setState(() {
                    if (isEditing && editIndex != null) {
                      _myTools[editIndex] = newTool;

                      // Also update in all tools
                      final allToolsIndex = _allTools.indexWhere(
                        (element) =>
                            element['name'] == tool['name'] &&
                            element['ownerName'] == 'You',
                      );
                      if (allToolsIndex != -1) {
                        _allTools[allToolsIndex] = {
                          ...newTool,
                          'ownerName': 'You',
                        };
                      }
                    } else {
                      _myTools.add(newTool);
                      _allTools.add({...newTool, 'ownerName': 'You'});
                    }
                  });

                  Navigator.pop(context);
                },
                child: Text(isEditing ? 'Update' : 'Add'),
              ),
            ],
          ),
    );
  }

  void _confirmDeleteTool(int index) {
    final tool = _myTools[index];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove Tool'),
            content: Text(
              'Are you sure you want to remove "${tool['name']}" from your tools?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  setState(() {
                    // Remove from all tools as well
                    _allTools.removeWhere(
                      (element) =>
                          element['name'] == tool['name'] &&
                          element['ownerName'] == 'You',
                    );
                    _myTools.removeAt(index);
                  });
                  Navigator.pop(context);
                },
                child: const Text('Remove'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment Marketplace'),
        backgroundColor: Colors.green[700],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'My Tools'), Tab(text: 'Browse Tools')],
        ),
      ),
      floatingActionButton:
          _tabController.index == 0
              ? FloatingActionButton(
                onPressed: () => _showAddToolDialog(),
                child: const Icon(Icons.add),
                backgroundColor: Colors.green,
              )
              : null,
      body: TabBarView(
        controller: _tabController,
        children: [
          // My Tools Tab
          _myTools.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.agriculture, size: 70, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text(
                      'You haven\'t added any tools yet',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => _showAddToolDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Your First Tool'),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _myTools.length,
                itemBuilder: (context, index) {
                  final tool = _myTools[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.network(
                            tool['image'],
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  height: 180,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(Icons.image, size: 50),
                                  ),
                                ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      tool['name'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          tool['isAvailable']
                                              ? Colors.green
                                              : Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      tool['isAvailable']
                                          ? 'Available'
                                          : 'Unavailable',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                tool['description'],
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.price_change,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    tool['price'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(tool['location']),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Edit button
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    color: Colors.blue,
                                    onPressed:
                                        () => _showAddToolDialog(tool: tool),
                                  ),
                                  // Delete button
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () => _confirmDeleteTool(index),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

          // Browse Tools Tab
          ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _allTools.length,
            itemBuilder: (context, index) {
              final tool = _allTools[index];
              final isMyTool = tool['ownerName'] == 'You';

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        tool['image'],
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              height: 180,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.image, size: 50),
                              ),
                            ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  tool['name'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      tool['isAvailable']
                                          ? Colors.green
                                          : Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  tool['isAvailable']
                                      ? 'Available'
                                      : 'Unavailable',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Owner: ${tool['ownerName']}",
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              if (isMyTool)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Your Tool',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            tool['description'],
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.price_change,
                                size: 16,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tool['price'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(tool['location']),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (!isMyTool && tool['isAvailable'])
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  onPressed:
                                      () => _launchCaller(tool['contact']),
                                  icon: const Icon(Icons.call, size: 16),
                                  label: const Text('Call'),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  onPressed:
                                      () => _launchWhatsApp(tool['contact']),
                                  icon: const Icon(Icons.message, size: 16),
                                  label: const Text('Message'),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
