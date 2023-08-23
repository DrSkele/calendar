part of calendar;

const TextStyle _defaultWeekdayStyle = TextStyle();
const TextStyle _defaultSaturdayStyle = TextStyle(color: Colors.blueAccent);
const TextStyle _defaultSundayStyle = TextStyle(color: Colors.redAccent);
const TextStyle _defaultDateStyle = TextStyle();
const TextStyle _defaultExtraDateStyle = TextStyle(color: Colors.grey);
const TextStyle _defaultSelectedDateStyle = TextStyle(color: Colors.white);
const Color _defaultIndicatorColor = Colors.redAccent;
const Size _defaultIndicatorSize = Size(26, 26);
const BoxShape _defaultIndicatorShape = BoxShape.circle;
const Color _defaultRangeColor = Color.fromRGBO(255, 166, 166, 1);
const double _defaultRangeHeight = 26;

class CalendarDecoration {
  const CalendarDecoration({
    this.weekdayStyle = const WeekdayStyle(),
    this.dateStyle = const DateStyle(),
  });

  final WeekdayStyle weekdayStyle;
  final DateStyle dateStyle;
}

class WeekdayStyle {
  const WeekdayStyle({
    this.weekdayStyle = _defaultWeekdayStyle,
    this.saturdayStyle = _defaultSaturdayStyle,
    this.sundayStyle = _defaultSundayStyle,
  });

  ///Textstyle of weekday texts in [daysofWeek] of calendars.
  final TextStyle weekdayStyle;

  ///Textstyle of saturday text in [daysofWeek] of calendars.
  final TextStyle saturdayStyle;

  ///Textstyle of sunday text in [daysofWeek] of calendars.
  final TextStyle sundayStyle;
}

class DateStyle {
  const DateStyle({
    this.saturdayStyle = _defaultSaturdayStyle,
    this.sundayStyle = _defaultSundayStyle,
    this.dateStyle = _defaultDateStyle,
    this.extraDateStyle = _defaultExtraDateStyle,
  });

  ///Textstyle of saturday dates in calendar.
  final TextStyle saturdayStyle;

  ///Textstyle of sunday dates in calendar.
  final TextStyle sundayStyle;

  ///Textstyle of weekday dates in calendar.
  final TextStyle dateStyle;

  ///Textstyle of dates in other months.
  ///
  ///Set to transparent in order to hide dates in other months.
  final TextStyle extraDateStyle;
}

class CalendarIndicator {
  const CalendarIndicator({
    this.selectedDateStyle = _defaultSelectedDateStyle,
    this.decoration = const BoxDecoration(
      color: _defaultIndicatorColor,
      shape: _defaultIndicatorShape,
    ),
    this.size = _defaultIndicatorSize,
  });

  ///Textstyle of selected date
  final TextStyle selectedDateStyle;

  final BoxDecoration decoration;

  ///Size of the selection indicator
  final Size size;
}
