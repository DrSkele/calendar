library calandar;

import 'package:calandar/week_extension.dart';
import 'package:flutter/material.dart';

part 'calandar_controller.dart';

enum _WeekDay {
  SUN(weekDay: 7),
  MON(weekDay: 1),
  TUE(weekDay: 2),
  WED(weekDay: 3),
  THU(weekDay: 4),
  FRI(weekDay: 5),
  SAT(weekDay: 6);

  const _WeekDay({required this.weekDay});
  final int weekDay;
  static _WeekDay parse(int weekDay) =>
      _WeekDay.values.singleWhere((element) => element.weekDay == weekDay);
}

const TextStyle _defaultWeekdayStyle = TextStyle();
const TextStyle _defaultDateStyle = TextStyle();
const Color _defaultColor = Colors.red;

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
    this.weekdaysStyle = _defaultWeekdayStyle,
    this.saturdayStyle = _defaultWeekdayStyle,
    this.sundayStyle = _defaultWeekdayStyle,
    this.dateStyle = _defaultDateStyle,
    this.indicatorColor = _defaultColor,
    this.indicator,
    this.onDateChange,
  });

  ///Controller of the WeeklyCalandar
  final CalandarController? controller;

  ///Height of the Calandar
  ///Default value is 100
  final double height;
  final TextStyle weekdaysStyle;
  final TextStyle saturdayStyle;
  final TextStyle sundayStyle;
  final TextStyle dateStyle;

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

  void _dateChangeListener() {
    final referenceWeek = _initialDate.startingSunday();
    final targetWeek = _calandarController.currentDate.startingSunday();
    final dateDifference = referenceWeek.difference(targetWeek).inDays;
    final weekDifference =
        (dateDifference <= 0 ? dateDifference / 7 : dateDifference.abs() / 7)
            .toInt();

    _pageController.animateToPage(
      _initialPage - weekDifference,
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
    return SizedBox(
      height: widget.height,
      child: PageView.builder(
        controller: _pageController,
        itemBuilder: (context, pageIndex) {
          final dateDifference = pageIndex - _initialPage;
          final referenceDate = (dateDifference == 0)
              ? _initialDate
              : _initialDate.add(Duration(days: 7 * dateDifference));
          final dateOfSunday = referenceDate.weekday == DateTime.sunday
              ? referenceDate
              : referenceDate.subtract(Duration(days: referenceDate.weekday));
          final weekDateList = List.generate(
              7, (index) => dateOfSunday.add(Duration(days: index)));
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDateList.map((e) => _getDateIndicator(e)).toList(),
          );
        },
      ),
    );
  }

  void _selectDate(DateTime date) {
    _calandarController.currentDate = date;
  }

  Widget _getDateIndicator(DateTime date) {
    return Column(
      children: [
        Text(
          _WeekDay.parse(date.weekday).name,
          style: (date.weekday == DateTime.sunday
              ? widget.sundayStyle
              : date.weekday == DateTime.saturday
                  ? widget.saturdayStyle
                  : widget.weekdaysStyle),
        ),
        GestureDetector(
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
                    style: widget.dateStyle,
                  ),
                ),
              ],
            ))
      ],
    );
  }
}
