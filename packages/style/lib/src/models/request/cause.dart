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

/// Request [Cause].
/// Indicates why this request is made.
enum Cause {
  /// Client request that received [Agent.ws] or [Agent.http].
  clientRequest,

  /// Requests created by triggers before the request was responded.
  requestTrigger,

  /// Requests created by triggers after the request is responded.
  responseTrigger,

  /// Requests created by [CronJobs]
  cronJobs,

  /// Requests created by [Admin]
  /// Admin is style monitoring app user or internal server coders
  admin,

  ///
  serverRequest,
}
