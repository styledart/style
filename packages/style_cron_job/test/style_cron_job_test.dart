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

import 'package:style_cron_job/src/style_cron_job_base.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test("runner", () async {
    every.x(3).second.listen((time) {
      print("Hello World!");
    });

    var runner = CronJobController();
    var count = 0;
    runner.add(each.second.asRunner((time) {
      count++;
    }));
    runner.add(each.second.asRunner((time) {
      count++;
    }));
    runner.add(each.second.asRunner((time) {
      count++;
    }));
    runner.start();
    await Future.delayed(Duration(seconds: 5));

    expect(count, 15);
  });

  test("second", () {
    var i = 0;
    var tCount = 0;
    var d = DateTime.now();
    var p = every.x(3).second;
    while (i < 10) {
      var t = d.add(Duration(seconds: i));
      var r = p.period.isNecessary(t);
      if (r) print(t);
      tCount += r ? 1 : 0;
      i++;
    }
    expect(tCount, 4);
  });

  test("second_cond", () {
    var i = 0;
    var tCount = 0;
    var d = DateTime.now();
    var check = 0;
    var p = every
        .x(10)
        .minute
        .fromNowOn(DateTime.now().add(Duration(seconds: 3)))
        .only((time) {
      check++;
      return time.second % 4 == 0;
    }).period;
    print(p.toTimeString());
    while (i < 15) {
      var t = d.add(Duration(seconds: i));
      var r = p.isNecessary(t);
      if (r) print(t);
      tCount += r ? 1 : 0;
      i++;
    }
    expect(check, 1);
    expect(tCount, 1);
  });

  test("each_minute", () {
    var i = 0;
    var tCount = 0;
    var time = DateTime(1970, 1, 1, 0, 0, 0, 300);
    while (i < 190) {
      var p = each.minute.atSecond(18);
      var t = time.add(Duration(seconds: i));
      var r = p.period.isNecessary(t);
      tCount += r ? 1 : 0;
      i++;
    }
    expect(tCount, 3);
  });

  test("each_x_minute", () {
    var stop = Stopwatch()..start();
    var i = 0;
    var tCount = 0;
    var time = DateTime(1995, 1, 1, 0, 0, 0, 300);
    var p = every.x(20).minute.atSecond(10).period;
    while (i < 60000) {
      var t = time.add(Duration(seconds: i));
      var r = p.isNecessary(t);

      tCount += r ? 1 : 0;
      i++;
    }
    stop.stop();
    print("each_x_minute: ms: ${stop.elapsedMilliseconds}");
    expect(tCount, 50);
  });

  test("each_hour", () {
    var stop = Stopwatch()..start();
    var i = 0;
    var tCount = 0;
    var time = DateTime(1995, 1, 1, 0, 0, 0, 300);
    var p = each.hour.atMinute(5).atSecond(10).period;
    while (i < 60000) {
      var t = time.add(Duration(seconds: i));
      var r = p.isNecessary(t);

      tCount += r ? 1 : 0;
      i++;
    }
    stop.stop();
    print("each_hour: ms: ${stop.elapsedMilliseconds}");
    expect(tCount, 17);
  });

  test("each_x_hour", () {
    var stop = Stopwatch()..start();
    var i = 0;
    var tCount = 0;
    var time = DateTime(1995, 1, 1, 0, 0, 0, 300);
    var p = every.x(3).hour.atMinute(5).atSecond(10).period;
    while (i < 60000) {
      var t = time.add(Duration(seconds: i));
      var r = p.isNecessary(t);
      if (r) print(t);
      tCount += r ? 1 : 0;
      i++;
    }
    stop.stop();
    print("each_hour: ms: ${stop.elapsedMilliseconds}");
    expect(tCount, 6);
  });

  test("each_day", () {
    var stop = Stopwatch()..start();
    var i = 0;
    var tCount = 0;
    var time = DateTime(1995, 1, 1, 0, 0, 0, 300);
    var p = each.day.atSecond(10).period;
    while (i < 600000) {
      var t = time.add(Duration(seconds: i));
      var r = p.isNecessary(t);

      tCount += r ? 1 : 0;
      i++;
    }
    stop.stop();
    print(
        "each_day: ${time.add(Duration(seconds: i))}"
            " ms: ${stop.elapsedMilliseconds}");
    expect(tCount, 7);
  });

  test("every_x_day", () {
    var stop = Stopwatch()..start();
    var i = 0;
    var tCount = 0;
    var time = DateTime(1995, 1, 1, 0, 0, 0, 300);
    var p = every.x(5).day.atSecond(10).period;
    while (i < 600000) {
      var t = time.add(Duration(seconds: i));
      var r = p.isNecessary(t);

      tCount += r ? 1 : 0;
      i++;
    }
    stop.stop();
    print("each_day: ms: ${stop.elapsedMilliseconds}");
    expect(tCount, 2);
  });

  test("each_week", () {
    var stop = Stopwatch()..start();
    var i = 0;
    var tCount = 0;
    var time = DateTime(2021, 8, 1, 0, 0, 0, 300);
    var p = each.week.atSecond(10).period;
    while (i < 605000 * 25) {
      var t = time.add(Duration(seconds: i));
      var r = p.isNecessary(t);
      if (r) {
        print("$r : $t");
      }
      tCount += r ? 1 : 0;
      i++;
    }
    stop.stop();
    print("each_week: ms: ${stop.elapsedMilliseconds}");
    expect(tCount, 25);
  });

  test("every_x_week", () {
    var stop = Stopwatch()..start();
    var i = 0;
    var tCount = 0;
    var time = DateTime(2021, 8, 1, 0, 0, 0, 300);
    var p = every.x(2).week.atSecond(10).period;
    while (i < 605000 * 25) {
      var t = time.add(Duration(seconds: i));
      var r = p.isNecessary(t);
      if (r) {
        print("$r : $t");
      }
      tCount += r ? 1 : 0;
      i++;
    }
    stop.stop();
    print("each_week: ms: ${stop.elapsedMilliseconds}");
    expect(tCount, 13);
  });

  test("each_month", () {
    var stop = Stopwatch()..start();
    var i = 0;
    var tCount = 0;
    var time = DateTime(2021, 8, 1, 0, 0, 0, 300);
    var p = every.x(2).month.atSecond(10).period;
    while (i < 605000 * 25) {
      var t = time.add(Duration(seconds: i));
      var r = p.isNecessary(t);
      if (r) {
        print("each_month $r : $t");
      }
      tCount += r ? 1 : 0;
      i++;
    }
    stop.stop();
    print("each_month: ms: ${stop.elapsedMilliseconds}");
    expect(tCount, 3);
  });
}
