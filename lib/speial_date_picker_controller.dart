import 'package:flutter/material.dart';

class SpecialDatePickerController {
  static SpecialDatePickerController? _instace;
  static SpecialDatePickerController get instance {
    if (_instace != null) return _instace!;
    _instace = SpecialDatePickerController._init();
    return _instace!;
  }

  SpecialDatePickerController._init();

  Map<String, int> getItemCount(
      {required DateTime date, required EDatePickerType datePickerType}) {
    int februaryRange = 28;
    int itemCount = 12;
    if (datePickerType == EDatePickerType.year) {
      itemCount = 110;
    } else if (datePickerType == EDatePickerType.month) {
      itemCount = 12;
      if (date.day > 28 &&
          date.year % 4 == 0 &&
          (date.year % 100 != 0 || date.year % 400 == 0)) {
        februaryRange = 29;
      }
    } else if (datePickerType == EDatePickerType.day) {
      if (date.month == 2) {
        if (date.year % 4 == 0 &&
            (date.year % 100 != 0 || date.year % 400 == 0)) {
          itemCount = 29;
        } else {
          itemCount = 28;
        }
      } else {
        switch (date.month) {
          case 1:
          case 3:
          case 5:
          case 7:
          case 8:
          case 10:
          case 12:
            itemCount = 31;
            break;
          case 4:
          case 6:
          case 9:
          case 11:
            itemCount = 30;
            break;
          default:
        }
      }
    }
    return {
      "itemCount": itemCount,
      "februaryRange": februaryRange,
    };
  }

  bool getSelectable({
    required bool isAgeLimit,
    required bool checkYear,
    required DateTime date,
    required int index,
    required int ageLimit,
    required int februaryRange,
    required EDatePickerType datePickerType,
  }) {
    final DateTime nowDate = DateTime.now();
    bool? selectable;
    if (isAgeLimit) {
      if (datePickerType == EDatePickerType.day) {
        if (checkYear &&
            (((nowDate.month <= date.month && index + 1 > nowDate.day)) ||
                date.month > nowDate.month)) {
          selectable = false;
        } else {
          selectable = true;
        }
      } else if (datePickerType == EDatePickerType.month) {
        if (checkYear &&
            (((index + 1 > nowDate.month) && (nowDate.day >= date.day)) ||
                date.day > nowDate.day)) {
          selectable = false;
          if (date.day > nowDate.day && index + 1 < nowDate.month) {
            selectable = true;
          }
          if (index == 1 && date.day > februaryRange) {
            selectable = false;
          }
        } else {
          selectable = true;
          if (index == 1 && date.day > februaryRange) {
            selectable = false;
          }
        }
      } else if (datePickerType == EDatePickerType.year) {
        if ((((date.month > nowDate.month) ||
                (date.month == nowDate.month && date.day > nowDate.day)) &&
            (index + nowDate.year - 106) > nowDate.year - ageLimit)) {
          selectable = false;
        } else {
          selectable = true;
        }
      }
    } else if (datePickerType == EDatePickerType.month) {
      if (index == 1 && date.day > februaryRange) {
        selectable = false;
      } else {
        selectable = true;
      }
    }
    return selectable ?? true;
  }
}

enum EDatePickerType {
  day(),
  month(),
  year();

  const EDatePickerType();
}

extension EDatePickerTypeExtension on EDatePickerType {
  GlobalKey get key {
    switch (this) {
      case EDatePickerType.day:
        return GlobalKey();
      case EDatePickerType.month:
        return GlobalKey();
      case EDatePickerType.year:
        return GlobalKey();
      default:
        return GlobalKey();
    }
  }
}

extension StringExtension on String {
  String get with0 => length == 1 ? "0$this" : this;
}
