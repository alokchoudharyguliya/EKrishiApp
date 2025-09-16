import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorContactScreen extends StatelessWidget {
  DoctorContactScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> doctors = [
    {
      'name': 'Dr. Ramesh Kumar',
      'degree': 'Ph.D. (Agronomy)',
      'type': 'Plant Doctor',
      'specialization': 'Crop Diseases, Soil Health',
      'place': 'Krishi Kendra, Lucknow',
      'phone': '+919876543210',
      'whatsapp': '+919876543210',
    },
    {
      'name': 'Dr. Anita Sharma',
      'degree': 'B.V.Sc & A.H.',
      'type': 'Veterinary Doctor',
      'specialization': 'Cattle, Poultry',
      'place': 'Vet Clinic, Kanpur',
      'phone': '+919812345678',
      'whatsapp': '+919812345678',
    },
    {
      'name': 'Dr. Suresh Patel',
      'degree': 'M.Sc. (Plant Pathology)',
      'type': 'Plant Doctor',
      'specialization': 'Pest Management',
      'place': 'Agro Center, Varanasi',
      'phone': '+919800112233',
      'whatsapp': '+919800112233',
    },
    {
      'name': 'Dr. Priya Singh',
      'degree': 'M.V.Sc.',
      'type': 'Veterinary Doctor',
      'specialization': 'Goat & Sheep',
      'place': 'Vet Hospital, Allahabad',
      'phone': '+919811223344',
      'whatsapp': '+919811223344',
    },
  ];

  Future<void> _launchCaller(String phone) async {
    final Uri url = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _launchSMS(String phone) async {
    final Uri url = Uri(scheme: 'sms', path: phone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    final String phoneNumber = phone.replaceAll('+', '').replaceAll(' ', '');
    final Uri url = Uri.parse('https://wa.me/$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact a Doctor'),
        backgroundColor: Colors.brown,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          final doc = doctors[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc['name'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${doc['degree']} • ${doc['type']}',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Specialization: ${doc['specialization']}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    'Place: ${doc['place']}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.phone, color: Colors.green[700], size: 18),
                      const SizedBox(width: 6),
                      Text(
                        doc['phone'] ?? '',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.call, color: Colors.green),
                        tooltip: 'Call',
                        onPressed: () => _launchCaller(doc['phone'] ?? ''),
                      ),
                      IconButton(
                        icon: const Icon(Icons.message, color: Colors.blue),
                        tooltip: 'Message',
                        onPressed: () => _launchSMS(doc['phone'] ?? ''),
                      ),
                      IconButton(
                        icon: const Icon(Icons.call, color: Colors.teal),
                        tooltip: 'WhatsApp',
                        onPressed: () => _launchWhatsApp(doc['whatsapp'] ?? ''),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
