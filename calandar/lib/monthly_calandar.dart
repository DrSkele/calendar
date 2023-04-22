part of calandar;

///Creates a row of dates displaying a single week.
///
///Date of the calandar can be controlled with [controller].
///Text representing the date and weekdays can be customized with [dateStyle], [weekdaysStyle], [saturdayStyle] and [sundayStyle].
///[indicatorColor] will be ignored if [indicator] is given.
///
///[onDateChange] is called when date is selected or changes with [controller].
class MonthlyCalandar extends StatefulWidget {
  const MonthlyCalandar({
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
  });

  ///Controller of the WeeklyCalandar
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

  @override
  State<MonthlyCalandar> createState() => _MonthlyCalandarState();
}

class _MonthlyCalandarState extends State<MonthlyCalandar> {
  final int _initialPage = 1040;

  late final PageController _pageController;
  late final CalandarController _calandarController;

  late final DateTime _initialDate;
  late DateTime _selectedDate;

  late Widget _indicator;

  void _dateChangeListener() {
    final targetDate = _calandarController.currentDate;
    final yearDifference = targetDate.year - _initialDate.year;
    final monthDifference =
        (yearDifference * 12) + (targetDate.month - _initialDate.month);

    _pageController.animateToPage(
      _initialPage + monthDifference,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );

    setState(() {
      _selectedDate = _calandarController.currentDate;
    });

    if (widget.onDateChange != null) widget.onDateChange!(_selectedDate);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _calandarController = widget.controller ?? CalandarController();
    _pageController = PageController(initialPage: _initialPage);
    _initialDate = _calandarController.currentDate;
    _selectedDate = _initialDate;
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
          children: List.generate(
              widget.daysOfWeek.length, (index) => _getDayOfWeek(index)),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemBuilder: (context, pageIndex) {
              final currentDate = _calandarController.currentDate;
              final daysInMonth =
                  DateUtils.getDaysInMonth(currentDate.year, currentDate.month);
              final monthStartingDate =
                  DateTime(currentDate.year, currentDate.month, 1);
              final monthLastDate =
                  DateTime(currentDate.year, currentDate.month, daysInMonth);
              final startingDate = monthStartingDate.startingSunday();

              final additionalDays = monthStartingDate.weekday % 7;
              final followingDays = 6 - (monthLastDate.weekday % 7);

              final daysList = List.generate(
                  additionalDays + daysInMonth + followingDays,
                  (index) => DateTime(startingDate.year, startingDate.month,
                      startingDate.day + index));

              return GridView.count(
                crossAxisCount: 7,
                children: List.generate(daysList.length,
                    (index) => _getDateIndicator(daysList[index])),
              );
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

  void _selectDate(DateTime date) {
    _calandarController.currentDate = date;
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
