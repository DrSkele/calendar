library calendar;

import 'calendar_date_extension.dart';
import 'package:flutter/material.dart';

part 'calendar_controller.dart';
part 'calendar_decoration.dart';
part 'modular_calendar_view.dart';

part 'modular_calendar_daysofweek.dart';
part 'calendar_range_controller.dart';
part 'modular_calendar_range_picker.dart';

enum _WeekDay {
  SUN(weekDay: 7),
  MON(weekDay: 1),
  TUE(weekDay: 2),
  WED(weekDay: 3),
  THU(weekDay: 4),
  FRI(weekDay: 5),
  SAT(weekDay: 6);

  const _WeekDay({required this.weekDay});
  final int weekDay;
  static _WeekDay parse(int weekDay) =>
      _WeekDay.values.singleWhere((element) => element.weekDay == weekDay);
}

const List<String> _defaultDayOfWeek = [
  'SUN',
  'MON',
  'TUE',
  'WED',
  'THU',
  'FRI',
  'SAT'
];
