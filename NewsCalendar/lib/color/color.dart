import 'package:flutter/material.dart';

class CalendarColors extends ThemeExtension<CalendarColors> {
  final Color pastEventBackground;
  final Color otherUserBackground;
  final Color userBackground;
  final Color selectedEventBackground;
  final Color todayEventBackground;
  final Color differentMonthBackground;

  final Color pastEventFont;
  final Color otherUserFont;
  final Color userFont;
  final Color selectedEventFont;
  final Color todayEventFont;
  final Color differentMonthFont;

  final Color pastEventBackgroundDark;
  final Color otherUserBackgroundDark;
  final Color userBackgroundDark;
  final Color selectedEventBackgroundDark;
  final Color todayEventBackgroundDark;
  final Color differentMonthBackgroundDark;

  final Color pastEventFontDark;
  final Color otherUserFontDark;
  final Color userFontDark;
  final Color selectedEventFontDark;
  final Color todayEventFontDark;
  final Color differentMonthFontDark;

  const CalendarColors({
    required this.pastEventBackground,
    required this.otherUserBackground,
    required this.userBackground,
    required this.selectedEventBackground,
    required this.todayEventBackground,
    required this.differentMonthBackground,
    required this.pastEventFont,
    required this.otherUserFont,
    required this.userFont,
    required this.selectedEventFont,
    required this.todayEventFont,
    required this.differentMonthFont,
    required this.pastEventBackgroundDark,
    required this.otherUserBackgroundDark,
    required this.userBackgroundDark,
    required this.selectedEventBackgroundDark,
    required this.todayEventBackgroundDark,
    required this.differentMonthBackgroundDark,
    required this.pastEventFontDark,
    required this.otherUserFontDark,
    required this.userFontDark,
    required this.selectedEventFontDark,
    required this.todayEventFontDark,
    required this.differentMonthFontDark,
  });

  @override
  ThemeExtension<CalendarColors> copyWith() => this;

  @override
  ThemeExtension<CalendarColors> lerp(
    ThemeExtension<CalendarColors>? other,
    double t,
  ) => this;
}
