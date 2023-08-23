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

  ///Whether date is in between given range.
  ///
  ///Excludes start and end date.
  ///
  ///Will always return false if second date is before or same as the first.
  bool isBetween(DateTime first, DateTime second) {
    if (isSameDate(first) || isSameDate(second) || !first.isBefore(second)) {
      return false;
    }
    return isAfter(first) && isBefore(second);
  }
}
