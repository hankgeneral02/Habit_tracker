import 'package:habittracker/time.dart';
import 'package:hive_flutter/hive_flutter.dart';

final _myBox = Hive.box("Habit_Database");

class HabitDatabase{
  List habitlist=[];
  Map<DateTime,int> heatMapDataSet={};

  void DefaultData()
  {
    habitlist=[["讀書",false],["運動",false],];

    _myBox.put("START_DATE",todaysDateFormatted());
  }

  void loadData()
  {
    if (_myBox.get(todaysDateFormatted()) == null) {
      habitlist = _myBox.get("CURRENT_HABIT_LIST");
      for (int i = 0; i < habitlist.length; i++) {
        habitlist[i][1] = false;
      }
    }
    else
      {
        habitlist=_myBox.get(todaysDateFormatted());
      }

  }

  void updateData()
  {
    _myBox.put(todaysDateFormatted(),habitlist);
    _myBox.put("CURRENT_HABIT_LIST",habitlist);
    calculateHabitPercentages();
    loadHeatMap();
  }


  void calculateHabitPercentages() {
    int countCompleted = 0;
    for (int i = 0; i < habitlist.length; i++) {
      if (habitlist[i][1] == true) {
        countCompleted++;
      }
    }

    String percent = habitlist.isEmpty
        ? '0.0'
        : (countCompleted / habitlist.length).toStringAsFixed(1);

    // key: "PERCENTAGE_SUMMARY_yyyymmdd"
    // value: string of 1dp number between 0.0-1.0 inclusive
    _myBox.put("PERCENTAGE_SUMMARY_${todaysDateFormatted()}", percent);
  }

  void loadHeatMap() {
    DateTime startDate = createDateTimeObject(_myBox.get("START_DATE"));

    // count the number of days to load
    int daysInBetween = DateTime.now().difference(startDate).inDays;

    // go from start date to today and add each percentage to the dataset
    // "PERCENTAGE_SUMMARY_yyyymmdd" will be the key in the database
    for (int i = 0; i < daysInBetween + 1; i++) {
      String yyyymmdd = convertDateTimeToString(
        startDate.add(Duration(days: i)),
      );

      double strengthAsPercent = double.parse(
        _myBox.get("PERCENTAGE_SUMMARY_$yyyymmdd") ?? "0.0",
      );

      // split the datetime up like below so it doesn't worry about hours/mins/secs etc.

      // year
      int year = startDate.add(Duration(days: i)).year;

      // month
      int month = startDate.add(Duration(days: i)).month;

      // day
      int day = startDate.add(Duration(days: i)).day;

      final percentForEachDay = <DateTime, int>{
        DateTime(year, month, day): (10 * strengthAsPercent).toInt(),
      };

      heatMapDataSet.addEntries(percentForEachDay.entries);
      print(heatMapDataSet);
    }
  }

}