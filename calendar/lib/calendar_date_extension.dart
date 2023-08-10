extension CalandarDate on DateTime {
  ///The past most recent Sunday of the date.
  DateTime startingSunday() {
    return subtract(Duration(days: weekday % 7));
  }

  DateTime endingSaturday() {
    return add(Duration(days: 6 - weekday % 7));
  }

  bool isSameMonth(DateTime other) {
    return month == other.month;
  }

  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
