/*
 * Copyright 2021 styledart.dev - Mehmet Yaz
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import 'dart:async';

import 'package:meta/meta.dart';

/// CronJobController manages multiple cron jobs
/// processes not started before calling [start]
///
class CronJobController {
  /// Use optional parameter [runners] or
  /// add later
  CronJobController([List<CronJobRunner>? runners]) : runners = runners ?? [];

  /// All Runners
  final List<CronJobRunner> runners;

  StreamSubscription? _subscription;

  /// !! Don't forget stop
  ///
  /// [start] define a [Stream.periodic] with 1 seconds.
  ///
  /// Each seconds checking runners must be calling.
  /// if yes, call runner's [onCall]
  ///
  void start() {
    _subscription = Stream.periodic(Duration(seconds: 1)).listen((event) {
      var t = DateTime.now();
      for (var runner in runners) {
        if (runner.period.isNecessary(t)) {
          runner.onCall(t);
        }
      }
    });
  }

  /// Stop Stream Subscription
  void stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  /// Add Runners.
  /// If already started, wait current checking and
  /// add to runners.
  ///
  /// Added runner call next seconds if necessary
  void add(CronJobRunner runner) async {
    runners.add(runner);
  }

  /// Remove Runners.
  /// If already started, wait current checking and
  /// remove from runners.
  ///
  /// Added runner don't call next
  void remove(CronJobRunner runner) async {
    runners.remove(runner);
  }
}

typedef CronCallback = FutureOr<void> Function(DateTime time);

/// Runner for each cron jobs
/// [onCall] call in period
@immutable
class CronJobRunner {
  CronJobRunner({required this.period, required this.onCall});

  final CronTimePeriod period;
  final CronCallback onCall;

  @override
  bool operator ==(Object other) {
    return other is CronJobRunner &&
        period.toTimeString() == other.period.toTimeString();
  }

  @override
  int get hashCode => period.toTimeString().hashCode;
}

/// Add condition to period
/// Checking condition on calling
typedef CronCondition = bool Function(DateTime time);

/// [each] is used for each month, week, day, hour, minute and second.
_EachPeriodBuilder get each => _EachPeriodBuilder();

/// [every] is used for needs such as once every 3 days, once every 2 months.
_EveryPeriodBuilder get every => _EveryPeriodBuilder();

class _PeriodBuilder {
  _PeriodBuilder();

  ///
  CronTimePeriod? _period;

  /// Add condition to period
  /// Checking condition on calling
  CronCondition? _condition;

  /// Stream creates event periodically
  Stream<DateTime> asStream() {
    return Stream.periodic(Duration(seconds: 1))
        .map<DateTime>((event) => DateTime.now())
        .where((event) => period.isNecessary(event));
  }

  StreamSubscription? _subscription;

  /// Listen calling periodically
  ///
  /// You can dispose with [dispose]
  ///
  void listen(void Function(DateTime time) fn) {
    _subscription = asStream().listen((event) {
      fn(event);
    });
  }

  /// If you
  void dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  /// Runner for Controller
  CronJobRunner asRunner(FutureOr<void> Function(DateTime time) fn) {
    return CronJobRunner(period: period, onCall: fn);
  }

  /// Set condition
  /// Run Function on necessary calling,
  /// if Function returns true operation started,
  /// else not.
  //ignore_for_file: use_setters_to_change_properties, avoid_returning_this
  _PeriodBuilder only(CronCondition? condition) {
    _condition = condition;
    return this;
  }

  /// Set sub-segments timepieces for defined type or now in default.
  /// Eg.
  /// ```dart
  /// each.day.fromNowOn(DateTime(1970, 1 , 1 , 16 , 30));
  /// // Each Day 16:30
  /// ```
  _PeriodBuilder fromNowOn([DateTime? time]) {
    time ??= DateTime.now();
    if (period is _MinuteMixin) {
      (period as _MinuteMixin)._second = time.second;
    }
    if (period is _HourMixin) {
      (period as _HourMixin)._minute = time.minute;
    }
    if (period is _DayMixin) {
      (period as _DayMixin)._hour = time.hour;
    }
    if (period is _WeekMixin) {
      (period as _WeekMixin)._weekDay = time.weekday;
    }
    if (period is _MonthMixin) {
      (period as _MonthMixin)._day = time.day;
    }
    return this;
  }

  /// Get Time Period for checking necessary for time
  CronTimePeriod get period {
    if (_period! is _MinuteMixin) {
      (_period as _MinuteMixin)._second ??= 0;
    }

    if (_period! is _HourMixin) {
      (_period as _HourMixin)._minute ??= 0;
    }

    if (_period! is _DayMixin) {
      (_period as _DayMixin)._hour ??= 0;
    }

    if (_period! is _WeekMixin) {
      (_period as _WeekMixin)._weekDay ??= 1;
    }

    if (_period! is _MonthMixin) {
      (_period as _MonthMixin)._day ??= 1;
    }

    _period!._condition = _condition;
    return _period!;
  }
}

class _EveryPeriodBuilder {
  _EveryXPeriod x(int x) {
    return _EveryXPeriod(x);
  }
}

class _EveryXPeriod extends _PeriodBuilder {
  _EveryXPeriod(this._every);

  final int _every;

  _MonthPeriodBuilder get month {
    return _MonthPeriodBuilder().._period = EveryXMonth(_every);
  }

  _WeekPeriodBuilder get week {
    return _WeekPeriodBuilder().._period = EveryXWeek(_every);
  }

  _DayPeriodBuilder get day {
    return _DayPeriodBuilder().._period = EveryXDay(_every);
  }

  _HourPeriodBuilder get hour {
    return _HourPeriodBuilder().._period = EveryXHour(_every);
  }

  _MinutePeriodBuilder get minute {
    return _MinutePeriodBuilder().._period = EveryXMinute(_every);
  }

  _PeriodBuilder get second {
    return _PeriodBuilder().._period = EveryXSecond(_every);
  }
}

class _EachPeriodBuilder extends _PeriodBuilder {
  _MonthPeriodBuilder get month {
    return _MonthPeriodBuilder().._period = EachMonth();
  }

  _WeekPeriodBuilder get week {
    return _WeekPeriodBuilder().._period = EachWeek();
  }

  _DayPeriodBuilder get day {
    return _DayPeriodBuilder().._period = EachDay();
  }

  _HourPeriodBuilder get hour {
    return _HourPeriodBuilder().._period = EachHour();
  }

  _MinutePeriodBuilder get minute {
    return _MinutePeriodBuilder().._period = EachMinute();
  }

  _PeriodBuilder get second {
    return _PeriodBuilder().._period = EveryXSecond(1);
  }
}

class _MinutePeriodBuilder extends _PeriodBuilder {
  _PeriodBuilder atSecond(int second) {
    assert(second >= 0 && second < 60);
    (period as _MinuteMixin)._second = second;
    return this;
  }
}

class _HourPeriodBuilder extends _MinutePeriodBuilder {
  _MinutePeriodBuilder atMinute(int minute) {
    assert(minute >= 0 && minute < 60);
    (period as _HourMixin)._minute = minute;
    return this;
  }
}

class _DayPeriodBuilder extends _HourPeriodBuilder {
  _HourPeriodBuilder atHour(int hour) {
    assert(hour >= 0 && hour < 24);
    (period as _DayMixin)._hour = hour;
    return this;
  }
}

class _WeekPeriodBuilder extends _DayPeriodBuilder {
  _DayPeriodBuilder onWeekDay(int day) {
    assert(day > 0 && day < 8);
    (period as _WeekMixin)._weekDay = day;
    return this;
  }
}

class _MonthPeriodBuilder extends _DayPeriodBuilder {
  /// On Month Day
  /// Must be  32 > x > 0
  _DayPeriodBuilder onDay(int day) {
    assert(day > 0 && day < 32);
    (period as _MonthMixin)._day = day;
    return this;
  }
}

/// Cron Time Period
abstract class CronTimePeriod {
  CronTimePeriod();

  /// Necessary working at time
  bool isNecessary(DateTime time);

  /// Detailed Description
  String toPeriodString();

  /// Description
  String toTimeString();

  CronCondition? _condition;


  /// Unix-cron Format https://man7.org/linux/man-pages/man5/crontab.5.html
  String unixCronFormat();
}

bool _isSameSecond(DateTime one, DateTime second) {
  return one.millisecondsSinceEpoch ~/ 1000 ==
      (second.millisecondsSinceEpoch ~/ 1000);
}

mixin _MinuteMixin on CronTimePeriod {
  int? _second;

  int get second => _second!;
}

mixin _HourMixin on CronTimePeriod {
  int? _minute;

  int get minute => _minute!;
}

mixin _DayMixin on CronTimePeriod {
  int? _hour;

  int get hour => _hour!;
}

mixin _MonthMixin on CronTimePeriod {
  int? _day;

  int get day => _day!;
}

mixin _WeekMixin on CronTimePeriod {
  int? _weekDay;

  int? get weekDay => _weekDay!;
}

/// Run each month one time of defined day , hour, minute, second
class EachMonth extends CronTimePeriod
    with _MonthMixin, _DayMixin, _HourMixin, _MinuteMixin {
  @override
  bool isNecessary(DateTime time) {
    var nTime = DateTime(time.year, time.month, day, hour, minute, second);
    return _isSameSecond(time, nTime) && (_condition?.call(time) ?? true);
  }

  @override
  String toPeriodString() {
    return "Each month one time"
        " running in [day:$day, hour:$hour,"
        " minute:$minute, seconds:$second]";
  }

  @override
  String toTimeString() {
    return "each_month_${day}_${hour}_${minute}_$second";
  }

  @override
  String unixCronFormat() {
    return "$minute $hour $day */1 *";
  }
}

/// Run each week one time of defined weekday , hour, minute, second
class EachWeek extends CronTimePeriod
    with _WeekMixin, _DayMixin, _HourMixin, _MinuteMixin {
  @override
  bool isNecessary(DateTime time) {
    var nTime = DateTime(time.year, time.month, time.day, hour, minute, second);
    return nTime.weekday == weekDay! &&
        _isSameSecond(time, nTime) &&
        (_condition?.call(time) ?? true);
  }

  @override
  String toPeriodString() {
    return "Each week one time weekDay:$weekDay,"
        " hour:$hour, minute:$minute, seconds:$second";
  }

  @override
  String toTimeString() {
    return "each_week_${weekDay}_${hour}_${minute}_$second";
  }

  @override
  String unixCronFormat() {
    return "$minute $hour * * */$weekDay";
  }
}

/// Run each day one time of defined hour, minute, second
class EachDay extends CronTimePeriod with _DayMixin, _HourMixin, _MinuteMixin {
  @override
  bool isNecessary(DateTime time) {
    var nTime = DateTime(time.year, time.month, time.day, hour, minute, second);
    return _isSameSecond(time, nTime) && (_condition?.call(time) ?? true);
  }

  @override
  String toPeriodString() {
    return "Each day one time hour:$hour, minute:$minute, seconds:$second";
  }

  @override
  String toTimeString() {
    return "each_day_${hour}_${minute}_$second";
  }

  @override
  String unixCronFormat() {
    return "$minute $hour * * *";
  }
}

/// Run each hour one time of defined  minute, second
class EachHour extends CronTimePeriod with _HourMixin, _MinuteMixin {
  @override
  bool isNecessary(DateTime time) {
    var nTime =
        DateTime(time.year, time.month, time.day, time.hour, minute, second);
    return _isSameSecond(time, nTime) && (_condition?.call(time) ?? true);
  }

  @override
  String toPeriodString() {
    return "Each day one time minute:$minute, seconds:$second";
  }

  @override
  String toTimeString() {
    return "each_hour_${minute}_$second";
  }

  @override
  String unixCronFormat() {
    return "$minute */1 * * *";
  }
}

/// Run each minute one time of defined  second
class EachMinute extends CronTimePeriod with _MinuteMixin {
  @override
  bool isNecessary(DateTime time) {
    var nTime = DateTime(
        time.year, time.month, time.day, time.hour, time.minute, second);
    return _isSameSecond(time, nTime) && (_condition?.call(time) ?? true);
  }

  @override
  String toPeriodString() {
    return "Each day one time seconds:$second";
  }

  @override
  String toTimeString() {
    return "each_minute_$second";
  }

  @override
  String unixCronFormat() {
    return "* * * * *";
  }
}

mixin EveryX on CronTimePeriod {
  ///
  DateTime _lastRun = DateTime(1970);

  /// Last Run
  DateTime get lastRun => _lastRun;

  /// Reset last run
  void reset([DateTime? time]) {
    _lastRun = time ?? DateTime.now();
  }
}

///
class EveryXMonth extends CronTimePeriod
    with _MonthMixin, _DayMixin, _HourMixin, _MinuteMixin, EveryX {
  ///
  EveryXMonth(this.month);

  ///
  final int month;

  @override
  bool isNecessary(DateTime time) {
    var nTime = DateTime(time.year, time.month, day, hour, minute, second);
    var each = _isSameSecond(time, nTime) && (_condition?.call(time) ?? true);

    var res = each &&
        (((time.month + (time.year * 12)) -
                (_lastRun.month + (_lastRun.year * 12))) >=
            month);
    if (res) {
      _lastRun = time;
    }
    return res;
  }

  @override
  String toPeriodString() {
    return "Every $month month one time running in [day:$day,"
        " hour:$hour, minute:$minute, seconds:$second]";
  }

  @override
  String toTimeString() {
    return "every_${month}_month_${day}_${hour}_${minute}_$second";
  }

  @override
  String unixCronFormat() {
    return "$minute $hour $day */$month *";
  }
}

///
class EveryXWeek extends CronTimePeriod
    with _WeekMixin, _DayMixin, _HourMixin, _MinuteMixin, EveryX {
  ///
  EveryXWeek(this.week);

  ///
  final int week;

  @override
  bool isNecessary(DateTime time) {
    var nTime = DateTime(time.year, time.month, time.day, hour, minute, second);
    var each = (weekDay == null || nTime.weekday == weekDay) &&
        _isSameSecond(time, nTime) &&
        (_condition?.call(time) ?? true);
    var difSec = time.difference(_lastRun).inSeconds;
    var weekSec = 7 * 24 * 60 * 60 * week;
    var res = each && (difSec > weekSec - 1);
    if (res) {
      _lastRun = time;
    }
    return res;
  }

  @override
  String toPeriodString() {
    return "Every $week week one time running in [weekday:$weekDay,"
        " hour:$hour, minute:$minute, seconds:$second]";
  }

  @override
  String toTimeString() {
    return "every_${week}_week_${weekDay}_${hour}_${minute}_$second";
  }

  @override
  String unixCronFormat() {
    throw UnimplementedError();
  }
}

class EveryXDay extends CronTimePeriod
    with _DayMixin, _HourMixin, _MinuteMixin, EveryX {
  ///
  EveryXDay(this.day);

  ///
  final int day;

  @override
  bool isNecessary(DateTime time) {
    var nTime = DateTime(time.year, time.month, time.day, hour, minute, second);
    var each = _isSameSecond(time, nTime) && (_condition?.call(time) ?? true);
    var difSec = time.difference(_lastRun).inSeconds;
    var daySec = 24 * 60 * 60 * day;
    var res = each && (difSec > daySec - 1);
    if (res) {
      _lastRun = time;
    }
    return res;
  }

  @override
  String toPeriodString() {
    return "Every $day day one time"
        " running in [hour:$hour,"
        " minute:$minute, seconds:$second]";
  }

  @override
  String toTimeString() {
    return "every_${day}_day_${hour}_${minute}_$second";
  }

  @override
  String unixCronFormat() {
    throw UnimplementedError();
  }
}

class EveryXHour extends CronTimePeriod with _HourMixin, _MinuteMixin, EveryX {
  ///
  EveryXHour(this.hour);

  ///
  final int hour;

  @override
  bool isNecessary(DateTime time) {
    var nTime =
        DateTime(time.year, time.month, time.day, time.hour, minute, second);
    var each = _isSameSecond(time, nTime) && (_condition?.call(time) ?? true);
    var difSec = time.difference(_lastRun).inSeconds;
    var hourSec = 60 * 60 * hour;
    var res = each && (difSec > hourSec - 1);
    if (res) {
      _lastRun = time;
    }
    return res;
  }

  @override
  String toPeriodString() {
    return "Every $hour hour one time running"
        " in [minute:$minute, seconds:$second]";
  }

  @override
  String toTimeString() {
    return "every_${hour}_hour_${minute}_$second";
  }

  @override
  String unixCronFormat() {
    throw UnimplementedError();
  }
}

///
class EveryXMinute extends CronTimePeriod with _MinuteMixin, EveryX {
  ///
  EveryXMinute(this.minute);

  //ignore_for_file: public_member_api_docs

  final int minute;

  @override
  bool isNecessary(DateTime time) {
    var nTime = DateTime(
        time.year, time.month, time.day, time.hour, time.minute, second);
    var each = _isSameSecond(time, nTime) && (_condition?.call(time) ?? true);
    var difSec = time.difference(_lastRun).inSeconds.abs();
    var minuteSec = 60 * minute;
    var res = each && (difSec > minuteSec - 1);
    if (res) {
      _lastRun = time;
    }
    return res;
  }

  @override
  String toPeriodString() {
    return "Every $minute minute one time running in [seconds:$second]";
  }

  @override
  String toTimeString() {
    return "every_${minute}_minute_$second";
  }

  @override
  String unixCronFormat() {
    throw UnimplementedError();
  }
}

class EveryXSecond extends CronTimePeriod with EveryX {
  EveryXSecond(this.second);

  int second;

  @override
  bool isNecessary(DateTime time) {
    if (second == 1) return true;
    var dif = time.difference(_lastRun).inMilliseconds.abs();
    var res = dif > (second * 1000) - 10 && (_condition?.call(time) ?? true);
    if (res) {
      _lastRun = time;
    }
    return res;
  }

  @override
  String toPeriodString() {
    return "Every $second hour one time running";
  }

  @override
  String toTimeString() {
    return "every_${second}_second";
  }

  @override
  String unixCronFormat() {
    throw UnimplementedError();
  }
}
