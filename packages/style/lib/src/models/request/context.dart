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

/// It refers to the context in which the request
/// occurs and the [BuildContext] of the endpoints and gates it reaches.
class RequestContext {
  /// Not use
  RequestContext(
      {required this.requestTime,
      required this.cause,
      required this.agent,
      required this.pathController,
      this.accessToken,
      this.tokenVerified = false});

  /// Path-Call Controller
  PathController pathController;

  /// Request Create Time
  DateTime requestTime;

  /// Request [Cause].
  /// Indicates why this request is made.
  Cause cause;

  /// [Request] agent.
  /// Example: The agent of all http/(s) requests received by the server is [Agent.http]
  Agent agent;

  ///
  bool tokenVerified;

  /// Access Token
  ///
  ///
  ///
  AccessToken? accessToken;
}
