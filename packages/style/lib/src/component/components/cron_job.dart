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

RandomGenerator _cronIDGenerator = RandomGenerator('#/l(5)');

///
class CronJob extends StatelessComponent {
  ///
  CronJob(
      {required this.timePeriod,
      required this.onCall,
      this.resetPeriodOnExternalCall = true,
      this.allowExternal = false,
      String? name})
      : name = name ?? 'cron_job_${_cronIDGenerator.generateString()}';

  ///
  final Future<Message?> Function(Request request, CronTimePeriod period)
      onCall;

  ///
  final CronTimePeriod timePeriod;

  ///
  final bool allowExternal;

  ///
  final bool resetPeriodOnExternalCall;

  ///
  final String name;

  @override
  StatelessBinding createBinding() => _CronJobBinding(this);

  @override
  Component build(BuildContext context) => Gate(
        child: Route(name,
            root: _CronJobEndpoint(
                resetPeriodOnExternalCall: resetPeriodOnExternalCall,
                name: name,
                timePeriod: timePeriod,
                onCall: onCall)),
        onRequest: (r) {
          if (r.context.cause != Cause.cronJobs && !allowExternal) {
            throw ForbiddenUnauthorizedException();
          }
          return r;
        });
}

class _CronJobBinding extends StatelessBinding {
  _CronJobBinding(StatelessComponent component) : super(component);

  @override
  // TODO: implement component
  CronJob get component => super.component as CronJob;

  @override
  void buildBinding() {
    super.buildBinding();
    owner.addCronJob('${getPath()}/${component.name}', component.timePeriod);
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

  @override
  void initState() {
    print('Cron Job Created with name: ${component.name}');
  }

  @override
  FutureOr<Object> onCall(Request request) async {
    var stw = Stopwatch()..start();
    await component.onCall(request, period);
    stw.stop();
    if (request is! CronJobRequest &&
        component.resetPeriodOnExternalCall &&
        period is EveryX) {
      (period as EveryX).reset();
    }
    return {
      'created': request.context.requestTime.toUtc().toString(),
      'took_ms': stw.elapsedMilliseconds,
      'path': request.fullPath
    };
  }
}
