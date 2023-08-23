part of calendar;

///Controller for the Calandar
class CalendarRangeController extends CalendarController {
  DateTime _startDate;
  DateTime? _endDate;

  DateTime get startDate => _startDate;
  DateTime? get endDate => _endDate;

  ///Creates a CalandarController
  ///
  ///Default value of [initialDate] is set to [DateTime.now]
  CalendarRangeController({DateTime? startDate, DateTime? endDate})
      : _startDate = startDate ?? DateTime.now(),
        super(initialDate: startDate ?? DateTime.now()) {
    super._currentDate = startDate ?? DateTime.now();
    _endDate = endDate;
  }

  void resetStartDate(DateTime date) {
    _startDate = date;
    _endDate = null;
    notifyListeners();
  }

  void setRange(DateTime start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }
}
