extension Week on DateTime {
  ///The past most recent Sunday of the date.
  DateTime startingSunday() {
    return subtract(Duration(days: weekday % 7));
  }
}
