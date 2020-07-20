import 'package:flutter/material.dart';

enum PartialType {
  hour,
  minute,
  amPm,
}

class TimeStamp with ChangeNotifier {
  PartialTimeStamp hour;
  PartialTimeStamp min;
  PartialTimeStamp amPm;

  DateTime get timeStamp {
    var hour24 = hour.selectedIndex;
    if (amPm.selectedIndex == 1) {
      hour24 += 12;
    }
    var time = DateTime(2020, 1, 1, hour24, min.selectedIndex);
    return time;
  }

  TimeStamp() {
    final now = DateTime.now();
    // hours
    hour = PartialTimeStamp();
    hour.items =
        Iterable<int>.generate(11).map((e) => ((e + 1)).toString()).toList();
    hour.items.insert(0, "12");
    hour.selectedIndex = now.hour % 12;

    // minutes
    min = PartialTimeStamp();
    min.items = Iterable<int>.generate(60).map((e) => (e).toString()).toList();
    min.selectedIndex = now.minute;

    // am/pm
    amPm = PartialTimeStamp();
    amPm.items = ["AM", "PM"];
    amPm.selectedIndex = now.hour > 12 ? 1 : 0;
  }

  PartialTimeStamp getPartial(PartialType type) {
    switch (type) {
      case PartialType.hour:
        return hour;
      case PartialType.minute:
        return min;
      case PartialType.amPm:
        return amPm;
      default:
        return null;
    }
  }
}

class PartialTimeStamp with ChangeNotifier {
  List<String> items;
  int selectedIndex;

  PartialTimeStamp({this.items, this.selectedIndex = 0});
}
