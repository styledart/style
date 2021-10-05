import 'package:style_cron_job/style_cron_job.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test("description", () {




    var r = each.day.atHour(4).atSecond(50)..only((time) => time.weekday != 4);

    r.asStream().listen((event) {
      //do
      // 10-4-21 04:00:50
      // 11-4-21 04:00:50
      // 11-4-21 04:00:50
    });



    var r2 = every.x(10).minute.atSecond(30);

    r2.listen((t) {
      //do
      // 10-4-21 10:25:30 //starting time
      // 10-4-21 10:35:30
    });


    every.x(5).week.onWeekDay(4);

    every.x(1).month.onDay(15).atHour(5);
    // ==
    each.month.onDay(15).atHour(5);




    print(r2);
    expect(r.period.toTimeString(), "each_day_4_0_0");
  });
}
