part of calendar;

class DaysOfWeek extends StatefulWidget {
  const DaysOfWeek({
    super.key,
    required this.daysOfWeek,
    required this.minItemSize,
    required this.weekdayStyle,
  });

  final List<String> daysOfWeek;
  final double minItemSize;

  final WeekdayStyle weekdayStyle;

  @override
  State<DaysOfWeek> createState() => _DaysOfWeekState();
}

class _DaysOfWeekState extends State<DaysOfWeek> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(
        widget.daysOfWeek.length,
        (index) => _getDayOfWeek(index),
      ),
    );
  }

  Widget _getDayOfWeek(int index) {
    return Flexible(
      flex: 1,
      child: SizedBox(
        height: widget.minItemSize,
        child: Center(
          child: Text(
            widget.daysOfWeek[index],
            style: index == 0 //sunday
                ? widget.weekdayStyle.sundayStyle
                : index == 6 //saturday
                    ? widget.weekdayStyle.saturdayStyle
                    : widget.weekdayStyle.weekdayStyle,
          ),
        ),
      ),
    );
  }
}
