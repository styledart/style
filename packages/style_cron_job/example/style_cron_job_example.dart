import 'package:style_cron_job/style_cron_job.dart';

void main() {
  every.x(10).second.listen((time) {
    print(time);
    // 2021-10-05 10:24:13.101423
    // 2021-10-05 10:24:23.101423
    // 2021-10-05 10:24:33.101420
  });
}