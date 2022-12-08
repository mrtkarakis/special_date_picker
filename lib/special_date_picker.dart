library special_date_picker;

import 'package:flutter/material.dart';
import 'package:special_date_picker/speial_date_picker_controller.dart';

late int _year;
late int _month;
late int _day;
const Color _purpleColor = Color(0xff8E99EF);
double _padding = 9;

double y = 0.0;
double x = 0.0;
double _appBarHeight = 0.0;

class SpecialDatePicker extends StatelessWidget {
  final DateTime? data;
  final Color selectebleColor;
  final Color listBoxColor;
  final Color textColor;
  final double? width;
  final BuildContext pageContext;
  final bool isAgeLimit;
  final int ageLimit;
  final double borderRadius;
  final double infoBoxHeight;
  final double? listHeight;
  final ValueChanged<DateTime>? onChanged;

  SpecialDatePicker({
    super.key,
    required this.data,
    this.selectebleColor = Colors.blue,
    this.listBoxColor = Colors.white,
    this.textColor = Colors.black,
    this.width,
    required this.pageContext,
    this.isAgeLimit = false,
    this.ageLimit = 18,
    this.borderRadius = 20,
    this.infoBoxHeight = 75,
    this.listHeight,
    this.onChanged,
  });

  static final SpecialDatePickerController _pickerController =
      SpecialDatePickerController.instance;

  static double listHeightLast = 0;
  late Size deviceSize;
  static late DateTime date;

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(pageContext).size;
    _appBarHeight = MediaQuery.of(context).viewPadding.top;
    final DateTime now = DateTime.now();

    date = data ??
        (isAgeLimit
            ? DateTime(now.year - ageLimit, now.month, now.day)
            : DateTime.now());

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        dateInfoBox(
          date: date,
          datePickerType: EDatePickerType.day,
          context: pageContext,
        ),
        dateInfoBox(
          date: date,
          datePickerType: EDatePickerType.month,
          context: pageContext,
        ),
        dateInfoBox(
          date: date,
          datePickerType: EDatePickerType.year,
          context: pageContext,
        ),
      ],
    );
  }

  Widget dateInfoBox({
    required DateTime date,
    required BuildContext context,
    required EDatePickerType datePickerType,
  }) {
    BoxDecoration decoration = BoxDecoration(
        border: Border.all(color: selectebleColor),
        borderRadius: BorderRadius.circular(borderRadius),
        color: selectebleColor.withOpacity(0.23));

    int value = 0;
    if (EDatePickerType.day == datePickerType) {
      _day = date.day;
      value = _day;
    } else if (datePickerType == EDatePickerType.month) {
      _month = date.month;
      value = _month;
    } else if (datePickerType == EDatePickerType.year) {
      _year = date.year;
      value = _year;
    }
    final GlobalKey globalKey = datePickerType.key;
    return Container(
      key: globalKey,
      width: width ?? deviceSize.width / 4.5,
      height: infoBoxHeight,
      decoration: decoration,
      child: TextButton(
        onPressed: () {
          final RenderBox box =
              globalKey.currentContext?.findRenderObject() as RenderBox;
          final Offset position = box.localToGlobal(Offset.zero);
          y = position.dy;
          x = position.dx;

          _appBarHeight = MediaQuery.of(context).viewPadding.top;
          listHeightLast = listHeight ??
              ((deviceSize.height / 2) - infoBoxHeight - (_padding + 12));
          final bool bottomToUp = (listHeightLast) - 10 < (y - _appBarHeight);

          showDialog(
            barrierColor: Colors.black.withOpacity(0.65),
            context: context,
            builder: (_) => datePicker(
              context,
              date: date,
              value: value,
              width: width ?? deviceSize.width / 4.5,
              datePickerType: datePickerType,
              bottomToUp: bottomToUp,
              data: data,
              borderRadius: borderRadius,
              isAgeLimit: isAgeLimit,
              ageLimit: ageLimit,
              topPadding: 0,
              textColor: textColor,
            ),
          );
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Center(
            child: Text(
              "$value".with0,
              style: TextStyle(
                  color: textColor, fontSize: 14, fontWeight: FontWeight.w400),
            ),
          ),
        ),
      ),
    );
  }

  Widget datePicker(
    BuildContext context, {
    required DateTime date,
    required int value,
    required double width,
    required double topPadding,
    required EDatePickerType datePickerType,
    required DateTime? data,
    bool isAgeLimit = false,
    Color textColor = Colors.black,
    int ageLimit = 18,
    double borderRadius = 20,
    bool bottomToUp = false,
  }) {
    bool selectable = true;
    DateTime nowDate = DateTime.now();
    PageController pageController = PageController(
      initialPage:
          value + (datePickerType == EDatePickerType.year ? -1916 : -4),
      viewportFraction: 0.14,
    );
    Widget selectDateList() {
      Widget listItem(int index) {
        String text = datePickerType == EDatePickerType.year
            ? "${index + nowDate.year - 107}".with0
            : "${index + 1}".with0;
        bool isSelect = text == "$value".with0;
        return Container(
          decoration: BoxDecoration(
              color: isSelect
                  ? _purpleColor.withOpacity(0.27)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(borderRadius * .7)),
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: TextButton(
            onPressed: selectable
                ? () {
                    setDate(datePickerType, index, nowDate, data, context);
                  }
                : null,
            style: TextButton.styleFrom(
                foregroundColor: _purpleColor,
                tapTargetSize: MaterialTapTargetSize.padded),
            child: FittedBox(
              child: Text(
                text,
                style: TextStyle(
                    color: isSelect
                        ? _purpleColor
                        : selectable
                            ? Colors.black
                            : Colors.grey,
                    fontSize: 16,
                    fontWeight: isSelect ? FontWeight.w600 : FontWeight.w500),
              ),
            ),
          ),
        );
      }

      Map<String, int> itemCountAndFebruary = _pickerController.getItemCount(
        date: date,
        datePickerType: datePickerType,
      );

      int itemCount = itemCountAndFebruary["itemCount"] ?? 0;
      int februaryRange = itemCountAndFebruary["februaryRange"] ?? 0;
      final bool checkYear = nowDate.year - date.year == ageLimit;

      return Container(
        height: listHeightLast,
        width: width - (18 / 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: listBoxColor,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              controller: pageController,
              itemCount: itemCount,
              itemBuilder: (BuildContext context, int index) {
                selectable = _pickerController.getSelectable(
                  isAgeLimit: isAgeLimit,
                  checkYear: checkYear,
                  date: date,
                  index: index,
                  ageLimit: ageLimit,
                  februaryRange: februaryRange,
                  datePickerType: datePickerType,
                );
                return listItem(index);
              }),
        ),
      );
    }

    Widget activeDateButton() {
      return Material(
        type: MaterialType.transparency,
        child: Container(
          height: infoBoxHeight - 2,
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: Colors.blue.withOpacity(.4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Center(
            child: Text(
              "$value".with0,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: textColor,
              ),
            ),
          ),
        ),
      );
    }

    _appBarHeight = MediaQuery.of(context).viewPadding.top;
    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        Positioned(
          left: x,
          top: bottomToUp ? null : y - _appBarHeight,
          bottom: bottomToUp
              ? deviceSize.height -
                  y -
                  infoBoxHeight +
                  1 -
                  (_appBarHeight > 25 ? _appBarHeight - 25 : 0)
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              bottomToUp ? selectDateList() : activeDateButton(),
              SizedBox(height: _padding),
              bottomToUp ? activeDateButton() : selectDateList(),
            ],
          ),
        ),
      ],
    );
  }

  void setDate(EDatePickerType datePickerType, int index, DateTime nowDate,
      DateTime? data, BuildContext context) {
    if (datePickerType == EDatePickerType.day) {
      _day = index + 1;
    }
    if (datePickerType == EDatePickerType.month) {
      _month = index + 1;
    }

    if (datePickerType == EDatePickerType.year) {
      _year = index + nowDate.year - 107;
    }

    data = DateTime(_year, _month, _day);
    onChanged?.call(data);

    Navigator.pop(context);
  }
}
