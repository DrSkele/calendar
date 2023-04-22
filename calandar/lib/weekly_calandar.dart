part of calandar;

///Creates a row of dates displaying a single week.
///
///Date of the calandar can be controlled with [controller].
///Text representing the date and weekdays can be customized with [dateStyle], [weekdaysStyle], [saturdayStyle] and [sundayStyle].
///[indicatorColor] will be ignored if [indicator] is given.
///
///[onDateChange] is called when date is selected or changes with [controller].
class WeeklyCalandar extends StatefulWidget {
  const WeeklyCalandar({
    super.key,
    this.controller,
    this.height = 100,
    this.showDaysOfWeek = true,
    this.daysOfWeek = _defaultDayOfWeek,
    this.weekdaysStyle = _defaultWeekdayStyle,
    this.saturdayStyle = _defaultSaturdayStyle,
    this.sundayStyle = _defaultSundayStyle,
    this.dateStyle = _defaultDateStyle,
    this.extraDateStyle = _defaultExtraDateStyle,
    this.selectedDateStyle = _defaultSelectedDateStyle,
    this.indicatorColor = _defaultColor,
    this.indicator,
    this.onDateChange,
  });

  ///Controller of the WeeklyCalandar
  final CalandarController? controller;

  ///Height of the Calandar
  ///Default value is 100
  final double height;

  final bool showDaysOfWeek;
  final List<String> daysOfWeek;
  final TextStyle weekdaysStyle;
  final TextStyle saturdayStyle;
  final TextStyle sundayStyle;

  final TextStyle dateStyle;
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
  State<WeeklyCalandar> createState() => _WeeklyCalandarState();
}

class _WeeklyCalandarState extends State<WeeklyCalandar> {
  final int _initialPage = 1040;

  late final PageController _pageController;
  late final CalandarController _calandarController;

  late final DateTime _initialDate;
  late DateTime _selectedDate;

  late Widget _indicator;

  bool isMoving = false;

  void _dateChangeListener() async {
    final referenceWeek = _initialDate.startingSunday();
    final targetWeek = _calandarController.currentDate.startingSunday();
    final dateDifference = referenceWeek.difference(targetWeek).inDays;
    final weekDifference =
        (dateDifference <= 0 ? dateDifference / 7 : dateDifference.abs() / 7)
            .toInt();

    setState(() {
      _selectedDate = _calandarController.currentDate;
    });
    isMoving = true;
    await _pageController.animateToPage(
      _initialPage - weekDifference,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
    isMoving = false;

    if (widget.onDateChange != null) widget.onDateChange!(_selectedDate);
  }

  void _onPageChanged(int page) {
    if (isMoving) return;
    final date = _initialDate
        .add(Duration(days: 7 * (page - _initialPage)))
        .startingSunday();
    _calandarController.currentDate = date;
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
            onPageChanged: _onPageChanged,
            itemBuilder: (context, pageIndex) {
              final dateDifference = pageIndex - _initialPage;
              final referenceDate = (dateDifference == 0)
                  ? _initialDate
                  : _initialDate.add(Duration(days: 7 * dateDifference));
              final dateOfSunday = referenceDate.weekday == DateTime.sunday
                  ? referenceDate
                  : referenceDate
                      .subtract(Duration(days: referenceDate.weekday));
              final weekDateList = List.generate(
                  7, (index) => dateOfSunday.add(Duration(days: index)));
              return GridView.count(
                shrinkWrap: true,
                crossAxisCount: 7,
                children: List.generate(weekDateList.length,
                    (index) => _getDateIndicator(weekDateList[index])),
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
    return GestureDetector(
      onTap: () => _selectDate(date),
      child: Stack(
        alignment: Alignment.center,
        children: [
          (date.day == _selectedDate.day)
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
              style: date.isSameDate(_selectedDate)
                  ? widget.selectedDateStyle
                  : date.isSameMonth(_selectedDate)
                      ? widget.dateStyle
                      : widget.extraDateStyle,
            ),
          ),
        ],
      ),
    );
  }
}
