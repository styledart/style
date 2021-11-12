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

part of '../../style_base.dart';

///
class CronJob extends StatelessComponent {
  ///
  CronJob(
      {required this.timePeriod,
      required this.onCall,
      this.resetPeriodOnExternalCall = true,
      String? name,
      GlobalKey? key})
      : name = name ?? "cron_job_${timePeriod.runtimeType}${getRandomId(5)}";

  ///
  final Future<Message?> Function(Request request, CronTimePeriod period)
      onCall;

  ///
  final CronTimePeriod timePeriod;

  ///
  final bool resetPeriodOnExternalCall;

  ///
  final String name;

  @override
  Component build(BuildContext context) {
    return Route(name,
        root: _CronJobEndpoint(
            name: name, timePeriod: timePeriod, onCall: onCall));
  }
}

///
class _CronJobEndpoint extends StatefulEndpoint {
  ///
  _CronJobEndpoint(
      {required this.timePeriod,
      required this.onCall,
      this.resetPeriodOnExternalCall = true,
      required this.name,
      GlobalKey? key})
      : super(key: key);

  ///
  final Future<Message?> Function(Request request, CronTimePeriod period)
      onCall;

  ///
  final CronTimePeriod timePeriod;

  ///
  final bool resetPeriodOnExternalCall;

  ///
  final String name;

  @override
  CronJobState createState() => CronJobState();
}

///
class CronJobState extends EndpointState<_CronJobEndpoint> {
  ///
  CronTimePeriod get period => component.timePeriod;

  void initState() {
    print("Cron Job Created with name: ${component.name}");
  }

  @override
  FutureOr<Message> onCall(Request request) async {
    if (request.cause != Cause.cronJobs && period is EveryX) {
      (period as EveryX).reset();
    }
    var stw = Stopwatch()..start();
    await component.onCall(request, period);
    stw..stop();
    return request.response({
      "created": request.context.requestTime.toUtc().toString(),
      "took_ms": stw.elapsedMilliseconds,
    });
  }
}
