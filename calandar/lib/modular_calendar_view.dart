part of calendar;

enum _CalendarType {
  week,
  month,
}

///Creates a view displaying dates.
///
///Date of the calandar can be controlled with [controller].
///Text representing the date and weekdays can be customized with [dateStyle], [weekdaysStyle], [saturdayStyle] and [sundayStyle].
///[indicatorColor] will be ignored if [indicator] is given.
///
///[onDateChange] is called when date is selected or changes with [controller].
class CalendarView extends StatefulWidget {
  const CalendarView.month({
    super.key,
    this.controller,
    this.showDaysOfWeek = true,
    this.daysOfWeek = _defaultDayOfWeek,
    this.weekdaysStyle = _defaultWeekdayStyle,
    this.saturdayStyle = _defaultSaturdayStyle,
    this.sundayStyle = _defaultSundayStyle,
    this.dateStyle = _defaultDateStyle,
    this.saturdayDateColor,
    this.sundayDateColor,
    this.extraDateStyle = _defaultExtraDateStyle,
    this.selectedDateStyle = _defaultSelectedDateStyle,
    this.indicatorColor = _defaultColor,
    this.indicator,
    this.onDateChange,
    this.onDateSelect,
    this.daysOfWeekAspectRatio = 1,
    this.dateAspectRatio = 1,
    this.physics,
  }) : type = _CalendarType.month;

  const CalendarView.week({
    super.key,
    this.controller,
    this.showDaysOfWeek = true,
    this.daysOfWeek = _defaultDayOfWeek,
    this.weekdaysStyle = _defaultWeekdayStyle,
    this.saturdayStyle = _defaultSaturdayStyle,
    this.sundayStyle = _defaultSundayStyle,
    this.dateStyle = _defaultDateStyle,
    this.saturdayDateColor,
    this.sundayDateColor,
    this.extraDateStyle = _defaultExtraDateStyle,
    this.selectedDateStyle = _defaultSelectedDateStyle,
    this.indicatorColor = _defaultColor,
    this.indicator,
    this.onDateChange,
    this.onDateSelect,
    this.daysOfWeekAspectRatio = 1,
    this.dateAspectRatio = 1,
    this.physics,
  }) : type = _CalendarType.week;

  final _CalendarType type;

  ///Controller of the CalandarView
  final CalandarController? controller;

  final bool showDaysOfWeek;
  final List<String> daysOfWeek;

  final TextStyle weekdaysStyle;
  final TextStyle saturdayStyle;
  final TextStyle sundayStyle;

  final TextStyle dateStyle;
  final Color? saturdayDateColor;
  final Color? sundayDateColor;
  final TextStyle extraDateStyle;
  final TextStyle selectedDateStyle;

  ///Color of the indicator
  ///Is not applied when [indicator] is not null
  final Color indicatorColor;

  ///A widget indicating the selected date.
  ///[indicatorColor] is ignored.
  final Widget? indicator;

  ///A callback on date change.
  ///Will be called when a date is selected or changed with [controller].
  final Function(DateTime date)? onDateChange;

  ///A callback on date selection.
  ///Will be called when a date is selected.
  final Function(DateTime date)? onDateSelect;

  final double daysOfWeekAspectRatio;
  final double dateAspectRatio;

  final ScrollPhysics? physics;

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final int _initialPage = 1040;
  late int _prevPage;

  late final PageController _pageController;
  late final CalandarController _calandarController;

  late final DateTime _initialDate;
  late DateTime _selectedDate;

  late Widget _indicator;

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

  void _selectDate(DateTime date) {
    _calandarController.currentDate = date;
    if (widget.onDateSelect != null) widget.onDateSelect!(date);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _calandarController = widget.controller ?? CalandarController();
    _pageController = PageController(initialPage: _initialPage);
    _initialDate = _calandarController.currentDate;
    _selectedDate = _initialDate;
    _prevPage = _initialPage;
    _calandarController.addListener(_dateChangeListener);

    //default indicator
    _indicator = widget.indicator ??
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.indicatorColor,
          ),
        );
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
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 7,
          childAspectRatio: widget.daysOfWeekAspectRatio,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(
              widget.daysOfWeek.length, (index) => _getDayOfWeek(index)),
        ),
        Flexible(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: widget.physics,
            itemBuilder: (context, pageIndex) {
              switch (widget.type) {
                case _CalendarType.week:
                  return _getWeeklyDateView(context, pageIndex);
                case _CalendarType.month:
                  return _getMontlyDateView(context, pageIndex);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _getDayOfWeek(int index) {
    return Center(
      child: Text(
        widget.daysOfWeek[index],
        style: index == 0 //sunday
            ? widget.sundayStyle
            : index == 6 //saturday
                ? widget.saturdayStyle
                : widget.weekdaysStyle,
      ),
    );
  }

  Widget _getMontlyDateView(BuildContext context, int pageIndex) {
    final currentDate = _calandarController.currentDate;
    final daysInMonth =
        DateUtils.getDaysInMonth(currentDate.year, currentDate.month);
    final monthStartingDate = DateTime(currentDate.year, currentDate.month, 1);
    final monthLastDate =
        DateTime(currentDate.year, currentDate.month, daysInMonth);
    final startingDate = monthStartingDate.startingSunday();

    final additionalDays = monthStartingDate.weekday % 7;
    final followingDays = 6 - (monthLastDate.weekday % 7);

    final daysList = List.generate(
        additionalDays + daysInMonth + followingDays,
        (index) => DateTime(
            startingDate.year, startingDate.month, startingDate.day + index));

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 7,
      childAspectRatio: widget.dateAspectRatio,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(
          daysList.length, (index) => _getDateIndicator(daysList[index])),
    );
  }

  Widget _getWeeklyDateView(BuildContext context, int pageIndex) {
    final dateDifference = pageIndex - _initialPage;
    final referenceDate = (dateDifference == 0)
        ? _initialDate
        : _initialDate.add(Duration(days: 7 * dateDifference));
    final dateOfSunday = referenceDate.weekday == DateTime.sunday
        ? referenceDate
        : referenceDate.subtract(Duration(days: referenceDate.weekday));
    final weekDateList =
        List.generate(7, (index) => dateOfSunday.add(Duration(days: index)));
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 7,
      childAspectRatio: widget.dateAspectRatio,
      children: List.generate(weekDateList.length,
          (index) => _getDateIndicator(weekDateList[index])),
    );
  }

  Widget _getDateIndicator(DateTime date) {
    final dateStyle = date.isSameDate(_selectedDate)
        ? widget.selectedDateStyle
        : date.isSameMonth(_selectedDate)
            ? date.weekday == DateTime.sunday && widget.sundayDateColor != null
                ? widget.dateStyle.copyWith(color: widget.sundayDateColor)
                : date.weekday == DateTime.saturday &&
                        widget.saturdayDateColor != null
                    ? widget.dateStyle.copyWith(color: widget.saturdayDateColor)
                    : widget.dateStyle
            : widget.extraDateStyle;

    return GestureDetector(
      onTap: () => _selectDate(date),
      child: Stack(
        alignment: Alignment.center,
        children: [
          date.isSameDate(_selectedDate)
              ? Center(child: _indicator)
              : Center(
                  child: Opacity(
                    opacity: 0,
                    child: _indicator,
                  ),
                ),
          Center(
            child: Text(
              date.day.toString(),
              style: dateStyle,
            ),
          ),
        ],
      ),
    );
  }
}
