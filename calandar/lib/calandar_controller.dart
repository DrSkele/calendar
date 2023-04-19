part of calandar;

///Controller for the Calandar
class CalandarController extends ChangeNotifier {
  DateTime _currentDate;
  final DateTime _initialDate;

  ///Current selected date of the calandar.
  ///Setting the value will notify listeners.
  set currentDate(DateTime date) {
    _currentDate = date;
    notifyListeners();
  }

  ///Current selected date of the calandar.
  DateTime get currentDate => _currentDate;

  ///Reference date used on creating the calandar.
  DateTime get initialDate => _initialDate;

  ///Creates a CalandarController
  ///
  ///Default value of [initialDate] is set to [DateTime.now]
  CalandarController({DateTime? initialDate})
      : _currentDate = initialDate ?? DateTime.now(),
        _initialDate = initialDate ?? DateTime.now();

  ///Change the [currentDate] to the first Sunday of upcoming week.
  void nextWeek() {
    _currentDate =
        _currentDate.add(Duration(days: 7 - (_currentDate.weekday % 7)));
    notifyListeners();
  }

  ///Change the [currentDate] to Saturday of the past week.
  void previousWeek() {
    _currentDate =
        _currentDate.subtract(Duration(days: (_currentDate.weekday % 7) + 1));
    notifyListeners();
  }
}
