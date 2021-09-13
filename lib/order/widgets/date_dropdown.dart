import 'package:calendar_time/calendar_time.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DateDropdown extends StatelessWidget {
  final dropdownState = GlobalKey<FormFieldState>();
  final ValueChanged<String?> onChanged;
  final String value;

  DateDropdown({required this.onChanged, required this.value});

  String getDisplayDate(DateTime d) {
    CalendarTime date = CalendarTime(d);
    if (date.isToday)
      return "Today";
    else if (date.isYesterday)
      return "Yesterday";
    else if (date.isTomorrow)
      return "Tomorrow";
    else
      return date.format("E, MMM d");
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> dates = [];
    DateTime today = DateTime.now();
    // build next 10 days
    for (int i = 0; i < 7; i++) {
      dates.add(today.add(Duration(days: i)));
    }
    return new DropdownButtonFormField<String>(
      key: dropdownState,
      decoration: InputDecoration(
        icon: Icon(Icons.calendar_today_outlined),
        labelText: "Date",
        hintText: "Select One",
      ),
      icon: Icon(Icons.arrow_drop_down),
      iconSize: 24,
      onChanged: onChanged,
      value: value,
      items: dates.map((d) {
        String display = getDisplayDate(d);
        return DropdownMenuItem(
          child: Text(display),
          value: display,
        );
      }).toList(),
      validator: (value) {
        if (value == null) {
          return "Please choose a date.";
        }
        return null;
      },
    );
  }
}
