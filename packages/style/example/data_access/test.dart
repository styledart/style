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

import 'package:style_dart/style_dart.dart';
import 'package:style_test/style_test.dart';

void main() async {
  var createTriggered = 0;
  var updateTriggered = 0;
  var writeTriggered = 0;
  Map<String, dynamic>? before;
  Map<String, dynamic>? after;
  var bind = await runService(Server(
      dataAccess: DataAccess(SimpleCacheDataAccess(),
          defaultPermission: true,
          collections: [
            /// create
            DbCollection("users",
                triggers: [
                  Trigger.onCreate(onEvent: (event) async {
                    print("On Create Triggered");
                    createTriggered++;
                    after = event.access.data;
                  }),
                  Trigger.onWrite(onEvent: (event) async {
                    print("On Write Triggered");
                    writeTriggered++;
                  }),
                  Trigger.onUpdate(
                      onEvent: (event) async {
                        print("BEFORE: ${event.before}\n"
                            "AFTER: ${event.after}");
                        before = event.before;
                        after = event.after;
                        updateTriggered++;
                      },
                      beforeNeed: true,
                      afterNeed: true)
                ])
          ]),
      children: [RestAccessPoint("api")]));

  var resS = (await bind.findCalling.calling(TestRequest(
      agent: Agent.http,
      cause: Cause.clientRequest,
      methods: Methods.POST,
      path: "/api/users",
      body: {"_id": "user1", "name": "Mehmet"}))) as Response;

  print(resS.body);
  print(resS.statusCode);
}
