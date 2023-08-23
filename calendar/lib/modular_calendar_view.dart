part of calendar;

enum _CalendarType {
  week,
  month,
}

///Creates a view displaying dates.
///
///[CalendarView.month] displays whole month.
///
///[CalendarView.week] displays only a week with 7 days.
///
///Date of the calandar can be controlled with [controller].
///Text representing the date and weekdays can be customized with [decoration].
///Selected date is displayed with [indicator].
///
///[onDateChange] is called when date is selected or changes with [controller].
class CalendarView extends StatefulWidget {
  const CalendarView.month({
    super.key,
    this.controller,
    this.showDaysOfWeek = true,
    this.daysOfWeek = _defaultDayOfWeek,
    this.decoration = const CalendarDecoration(),
    this.indicator = const CalendarIndicator(),
    this.onDateChange,
    this.onDateSelect,
    this.minDaysOfWeekHieght = 26,
    this.dateItemMinHeight = 26,
    this.physics,
  }) : type = _CalendarType.month;

  const CalendarView.week({
    super.key,
    this.controller,
    this.showDaysOfWeek = true,
    this.daysOfWeek = _defaultDayOfWeek,
    this.decoration = const CalendarDecoration(),
    this.indicator = const CalendarIndicator(),
    this.onDateChange,
    this.onDateSelect,
    this.minDaysOfWeekHieght = 26,
    this.dateItemMinHeight = 26,
    this.physics,
  }) : type = _CalendarType.week;

  final _CalendarType type;

  ///Controller of the CalandarView
  final CalendarController? controller;

  final bool showDaysOfWeek;
  final List<String> daysOfWeek;

  final CalendarDecoration decoration;
  final CalendarIndicator indicator;

  ///A callback on date change.
  ///Will be called when a date is selected or changed with [controller].
  final Function(DateTime date)? onDateChange;

  ///A callback on date selection.
  ///Will be called when a date is selected.
  final Function(DateTime date)? onDateSelect;

  final double minDaysOfWeekHieght;
  final double dateItemMinHeight;

  final ScrollPhysics? physics;

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final int _initialPage = 1040;
  late int _prevPage;

  late final PageController _pageController;
  late final CalendarController _calandarController;

  late final DateTime _initialDate;
  late DateTime _selectedDate;

  bool isMoving = false;

  void _dateChangeListener() async {
    setState(() {
      _selectedDate = _calandarController.currentDate;
    });

    isMoving = true;
    await _pageController.animateToPage(
      _getNewPageIndex(),
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
    isMoving = false;

    if (widget.onDateChange != null) widget.onDateChange!(_selectedDate);
  }

  int _getNewPageIndex() {
    switch (widget.type) {
      case _CalendarType.week:
        final referenceWeek = _initialDate.startingSunday();
        final targetWeek = _calandarController.currentDate.startingSunday();
        final dateDifference = referenceWeek.difference(targetWeek).inDays;
        final weekDifference = (dateDifference <= 0
                ? dateDifference / 7
                : dateDifference.abs() / 7)
            .toInt();
        return _initialPage - weekDifference;
      case _CalendarType.month:
        final targetDate = _calandarController.currentDate;
        final yearDifference = targetDate.year - _initialDate.year;
        final monthDifference =
            (yearDifference * 12) + (targetDate.month - _initialDate.month);
        return _initialPage + monthDifference;
    }
  }

  void _onPageChanged(int page) {
    if (isMoving) return;
    _calandarController.currentDate = _getNewDate(page);
  }

  DateTime _getNewDate(int page) {
    switch (widget.type) {
      case _CalendarType.week:
        final direction = page - _prevPage > 0;
        final date =
            _initialDate.add(Duration(days: 7 * (page - _initialPage)));
        _prevPage = page;
        return direction ? date.startingSunday() : date.endingSaturday();
      case _CalendarType.month:
        return DateTime(
            _initialDate.year, _initialDate.month + (page - _initialPage), 1);
    }
  }

  void _onSelectDate(DateTime date) {
    _calandarController.currentDate = date;
    if (widget.onDateSelect != null) widget.onDateSelect!(date);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _calandarController = widget.controller ?? CalendarController();
    _pageController = PageController(initialPage: _initialPage);
    _initialDate = _calandarController.currentDate;
    _selectedDate = _initialDate;
    _prevPage = _initialPage;
    _calandarController.addListener(_dateChangeListener);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _calandarController.removeListener(_dateChangeListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DaysOfWeek(
          daysOfWeek: widget.daysOfWeek,
          minItemSize: widget.minDaysOfWeekHieght,
          weekdayStyle: widget.decoration.weekdayStyle,
        ),
        Flexible(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: widget.physics,
            itemBuilder: (context, pageIndex) {
              return CalendarDates(
                type: widget.type,
                currentDate: _calandarController.currentDate,
                selectedDate: _selectedDate,
                style: widget.decoration.dateStyle,
                indicator: widget.indicator,
                dateMinHeight: widget.dateItemMinHeight,
                onDateSelect: _onSelectDate,
              );
            },
          ),
        ),
      ],
    );
  }
}

class CalendarDates extends StatefulWidget {
  const CalendarDates({
    super.key,
    required this.type,
    required this.currentDate,
    required this.selectedDate,
    required this.style,
    required this.indicator,
    required this.dateMinHeight,
    required this.onDateSelect,
  });

  final _CalendarType type;
  final DateTime currentDate;
  final DateTime selectedDate;
  final DateStyle style;
  final CalendarIndicator indicator;
  final double dateMinHeight;

  final Function(DateTime date) onDateSelect;

  @override
  State<CalendarDates> createState() => _CalendarDatesState();
}

class _CalendarDatesState extends State<CalendarDates> {
  List<DateTime> getMontlyDays() {
    final currentDate = widget.currentDate;
    final daysInMonth =
        DateUtils.getDaysInMonth(currentDate.year, currentDate.month);
    final monthStartingDate = DateTime(currentDate.year, currentDate.month, 1);
    final monthLastDate =
        DateTime(currentDate.year, currentDate.month, daysInMonth);
    final startingDate = monthStartingDate.startingSunday();

    final additionalDays = monthStartingDate.weekday % 7;
    final followingDays = 6 - (monthLastDate.weekday % 7);

    return List.generate(
        additionalDays + daysInMonth + followingDays,
        (index) => DateTime(
            startingDate.year, startingDate.month, startingDate.day + index));
  }

  List<DateTime> getWeeklyDays() {
    final currentDate = widget.currentDate;
    final dateOfSunday = currentDate.weekday == DateTime.sunday
        ? currentDate
        : currentDate.subtract(Duration(days: currentDate.weekday));
    return List.generate(7, (index) => dateOfSunday.add(Duration(days: index)));
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final days =
        widget.type == _CalendarType.month ? getMontlyDays() : getWeeklyDays();

    final List<Widget> dates = List.generate(
      days.length,
      (index) => _getDateIndicator(days[index]),
    );

    final List<Widget> weeks = [];
    for (int i = 0; i < dates.length / 7; i++) {
      weeks.add(
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: dates.sublist(i * 7, (i + 1) * 7),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: weeks,
    );
  }

  Widget _getDateIndicator(DateTime date) {
    final selectedStyle = widget.indicator.selectedDateStyle;

    final dateStyle = !date.isSameMonth(widget.selectedDate)
        ? widget.style.extraDateStyle
        : date.weekday == DateTime.sunday
            ? widget.style.sundayStyle
            : date.weekday == DateTime.saturday
                ? widget.style.saturdayStyle
                : widget.style.dateStyle;

    final indicator = Container(
      width: widget.indicator.size.width,
      height: widget.indicator.size.height,
      decoration: widget.indicator.decoration,
    );

    final isSameDate = date.isSameDate(widget.selectedDate);

    return Flexible(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => widget.onDateSelect(date),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: widget.dateMinHeight),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isSameDate)
                Center(
                  child: indicator,
                ),
              Center(
                child: Text(
                  date.day.toString(),
                  style: isSameDate ? selectedStyle : dateStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
