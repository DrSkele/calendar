part of calendar;

///Creates a view displaying dates.
///
///Date of the calandar can be controlled with [controller].
///Text representing the date and weekdays can be customized with [decoration].
///Selected date is displayed with [indicator].
///Selected range is highlighted with [rangeColor].
///
///[onRangeSelect] is called when start date and end date is both selected
///or changes with [controller].
///
class CalendarRangePickerView extends StatefulWidget {
  const CalendarRangePickerView({
    super.key,
    this.controller,
    this.decoration = const CalendarDecoration(),
    this.indicator = const CalendarIndicator(),
    this.showDaysOfWeek = true,
    this.daysOfWeek = _defaultDayOfWeek,
    this.rangeColor = _defaultRangeColor,
    this.rangeHeight = _defaultRangeHeight,
    this.onPageChange,
    this.onRangeSelect,
    this.minDaysOfWeekHieght = 26,
    this.dateItemMinHeight = 26,
    this.physics,
  });

  ///Controller of the CalandarView
  final CalendarRangeController? controller;

  final CalendarDecoration decoration;
  final CalendarIndicator indicator;

  final bool showDaysOfWeek;
  final List<String> daysOfWeek;

  ///Color of the selected range
  final Color rangeColor;

  ///Height of the selected range
  final double rangeHeight;

  ///A callback on date change.
  ///Will be called when a date is selected or changed with [controller].
  final Function(DateTime date)? onPageChange;

  ///A callback on date selection.
  ///Will be called when a date is selected.
  final Function(DateTime start, DateTime end)? onRangeSelect;

  final double minDaysOfWeekHieght;
  final double dateItemMinHeight;

  final ScrollPhysics? physics;

  @override
  State<CalendarRangePickerView> createState() => _CalendarRangePickerView();
}

class _CalendarRangePickerView extends State<CalendarRangePickerView> {
  final int _initialPage = 1040;

  late final PageController _pageController;
  late final CalendarRangeController _calandarController;

  bool isMoving = false;

  late DateTime _startDate;
  DateTime? _endDate;

  void _dateChangeListener() async {
    setState(() {});
    isMoving = true;
    await _pageController.animateToPage(
      _getNewPageIndex(),
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
    isMoving = false;

    if (widget.onPageChange != null)
      widget.onPageChange!(_calandarController.currentDate);
  }

  int _getNewPageIndex() {
    final targetDate = _calandarController.currentDate;
    final yearDifference =
        targetDate.year - _calandarController.initialDate.year;
    final monthDifference = (yearDifference * 12) +
        (targetDate.month - _calandarController.initialDate.month);
    return _initialPage + monthDifference;
  }

  void _selectDate(DateTime date) {
    setState(() {
      if (_calandarController.endDate == null) {
        //currently only has start date
        if (date.isAfter(_startDate)) {
          //selected end date
          _endDate = date;
        } else if (date.isBefore(_startDate)) {
          //selected alternative start date
          _endDate = _startDate;
          _startDate = date;
        } else {
          //select already selected start date without end date
          return;
        }
        _calandarController.setRange(_startDate, _endDate);
        if (widget.onRangeSelect != null) {
          widget.onRangeSelect!(_startDate, _endDate!);
        }
      } else {
        //has both end and start date
        if (date.isSameDate(_startDate)) {
          //unselect start date
          _startDate = _endDate!;
          _endDate = null;
        } else if (date.isSameDate(_endDate!)) {
          //unselect end date
          _endDate = null;
        } else {
          //select new start date
          _startDate = date;
          _endDate = null;
        }
        _calandarController.resetStartDate(_startDate);
      }
    });
  }

  void _onPageChanged(int page) {
    if (isMoving) return;
    _calandarController.currentDate = DateTime(
      _calandarController.initialDate.year,
      _calandarController.initialDate.month + (page - _initialPage),
      1,
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _calandarController = widget.controller ?? CalendarRangeController();
    _startDate = _calandarController.startDate;
    _endDate = _calandarController.endDate;
    _calandarController.addListener(_dateChangeListener);

    _pageController = PageController(initialPage: _initialPage);
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
              return MonthlyRangeDate(
                currentMonth: _calandarController.currentDate,
                startDate: _startDate,
                endDate: _endDate,
                style: widget.decoration.dateStyle,
                indicator: widget.indicator,
                dateMinHeight: widget.dateItemMinHeight,
                rangeColor: widget.rangeColor,
                rangeHeight: widget.rangeHeight,
                onDateSelect: _selectDate,
              );
            },
          ),
        ),
      ],
    );
  }
}

class MonthlyRangeDate extends StatefulWidget {
  const MonthlyRangeDate({
    super.key,
    required this.currentMonth,
    required this.startDate,
    this.endDate,
    required this.style,
    required this.indicator,
    required this.dateMinHeight,
    required this.rangeColor,
    required this.rangeHeight,
    required this.onDateSelect,
  });

  final DateTime currentMonth;
  final DateTime startDate;
  final DateTime? endDate;
  final DateStyle style;
  final CalendarIndicator indicator;
  final double dateMinHeight;
  final Color rangeColor;
  final double rangeHeight;

  final Function(DateTime date) onDateSelect;

  @override
  State<MonthlyRangeDate> createState() => _MonthlyRangeDateState();
}

class _MonthlyRangeDateState extends State<MonthlyRangeDate> {
  List<DateTime> getDays() {
    final currentMonth = widget.currentMonth;
    final daysInMonth =
        DateUtils.getDaysInMonth(currentMonth.year, currentMonth.month);
    final monthStartingDate =
        DateTime(currentMonth.year, currentMonth.month, 1);
    final monthLastDate =
        DateTime(currentMonth.year, currentMonth.month, daysInMonth);
    final startingDate = monthStartingDate.startingSunday();

    final additionalDays = monthStartingDate.weekday % 7;
    final followingDays = 6 - (monthLastDate.weekday % 7);

    return List.generate(
        additionalDays + daysInMonth + followingDays,
        (index) => DateTime(
            startingDate.year, startingDate.month, startingDate.day + index));
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final days = getDays();

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

    final TextStyle dateStyle = !date.isSameMonth(widget.currentMonth)
        ? widget.style.extraDateStyle
        : date.weekday == DateTime.sunday
            ? widget.style.sundayStyle
            : date.weekday == DateTime.saturday
                ? widget.style.saturdayStyle
                : widget.style.dateStyle;

    final isStartDate = date.isSameDate(widget.startDate);
    final isEndDate =
        widget.endDate != null && date.isSameDate(widget.endDate!);
    final isBetween = widget.endDate != null &&
        date.isBetween(widget.startDate, widget.endDate!);

    late final _BackgroundPaint background;
    if (widget.endDate == null) {
      background = _BackgroundPaint.none;
    } else {
      if (isBetween) {
        background = _BackgroundPaint.both;
      } else if (isStartDate) {
        background = _BackgroundPaint.right;
      } else if (isEndDate) {
        background = _BackgroundPaint.left;
      } else {
        background = _BackgroundPaint.none;
      }
    }

    final painter = _CustomRangePainter(
      color: widget.rangeColor,
      height: widget.rangeHeight,
      style: background,
    );

    final indicator = Container(
      width: widget.indicator.size.width,
      height: widget.indicator.size.height,
      decoration: widget.indicator.decoration,
    );

    return Flexible(
      child: GestureDetector(
        onTap: () => widget.onDateSelect(date),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: widget.dateMinHeight),
          child: CustomPaint(
            painter: painter,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isStartDate || isEndDate)
                  Center(
                    child: indicator,
                  ),
                Center(
                  child: Text(
                    date.day.toString(),
                    style: isStartDate || isEndDate ? selectedStyle : dateStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _BackgroundPaint { none, left, right, both }

class _CustomRangePainter extends CustomPainter {
  _CustomRangePainter({
    required this.color,
    required this.height,
    this.style = _BackgroundPaint.none,
  });

  final double height;
  final Color color;
  final _BackgroundPaint style;

  @override
  void paint(Canvas canvas, Size size) {
    if (style == _BackgroundPaint.none) {
      return;
    }

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Rect rectLeft = Rect.fromLTWH(
        0, size.height / 2 - height / 2, size.width / 2 + 1, height);
    final Rect rectRight = Rect.fromLTWH(size.width / 2,
        size.height / 2 - height / 2, size.width / 2 + 1, height);
    final Rect rectBoth =
        Rect.fromLTWH(0, size.height / 2 - height / 2, size.width + 1, height);

    switch (style) {
      case _BackgroundPaint.right:
        canvas.drawRect(
          rectRight,
          paint,
        );
        break;
      case _BackgroundPaint.left:
        canvas.drawRect(
          rectLeft,
          paint,
        );
        break;
      case _BackgroundPaint.both:
        canvas.drawRect(
          rectBoth,
          paint,
        );
        break;
      case _BackgroundPaint.none:
        break;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
