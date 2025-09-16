import 'package:flutter/material.dart';

class DifferentMonthDay extends StatelessWidget {
  final DateTime day;
  final Color backgroundColor;
  final Color fontColor;
  final bool isWeekend;
  final bool isDarkMode;

  const DifferentMonthDay({
    Key? key,
    required this.day,
    required this.backgroundColor,
    required this.fontColor,
    required this.isWeekend,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(color: backgroundColor),
        child: Center(
          child: Text(
            day.day.toString(),
            style: TextStyle(
              fontSize: 18,
              color:
                  isWeekend
                      ? (isDarkMode ? Colors.red[300]! : Colors.red[300]!)
                      : fontColor,
            ),
          ),
        ),
      ),
    );
  }
}
