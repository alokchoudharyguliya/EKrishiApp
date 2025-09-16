import 'package:flutter/material.dart';

class WeatherDay extends StatelessWidget {
  final String day;
  final IconData icon;
  final Color color;

  const WeatherDay({
    Key? key,
    required this.day,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          day,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 18),
        ),
      ],
    );
  }
}