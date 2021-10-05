part of '../../style_base.dart';

///
class CronJob extends StatefulComponent {
  ///
  CronJob(
      {required this.timePeriod,
      required this.onCall,
      this.callAgain = true,
      this.callOnStateClosed = false,
      String? name,
      GlobalKey? key})
      : name = name ?? "cron_job_${timePeriod.runtimeType}${getRandomId(5)}",
        super(key: key);

  ///
  final Future<Message?> Function(Request request, CronJobState state) onCall;

  ///
  final CronTimePeriod timePeriod;

  ///
  final bool callAgain;

  ///
  final String name;

  ///
  final bool callOnStateClosed;

  @override
  CronJobState createState() => CronJobState();
}

///
class CronJobState extends State<CronJob> {
  int totalCallCount = 0;
  DateTime? lastCall;

  CronTimePeriod get period => component.timePeriod;

  @override
  Component build(BuildContext context) {
    return SimpleEndpoint((request) async {
      totalCallCount++;
      lastCall = DateTime.now();
      return (await component.onCall(request, this)) ??
          NoResponseRequired(request: request);
    });
    return UnknownEndpoint();
  }
}
