/*
 * Copyright 2021 styledart.dev - Mehmet Yaz
 *
 * Licensed under the GNU AFFERO GENERAL PUBLIC LICENSE, Version 3 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       https://www.gnu.org/licenses/agpl-3.0.en.html
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import 'package:style_dart/src/style_base.dart';
import 'package:style_test/style_test.dart';

void main() async {
  var createTriggered = 0;
  var updateTriggered = 0;
  var writeTriggered = 0;
  Map<String, dynamic>? before;
  Map<String, dynamic>? after;

  await initStyleTester(
      'trigger',
      Server(
          dataAccess: DataAccess(SimpleCacheDataAccess(),
              defaultPermission: true,
              collections: [
                /// create
                DbCollection('users', triggers: [
                  Trigger.onCreate(onEvent: (event) async {
                    print('On Create Triggered');
                    createTriggered++;
                    after = event.access.create!.toMap();
                  }),
                  Trigger.onWrite(onEvent: (event) async {
                    print('On Write Triggered');
                    writeTriggered++;
                  }),
                  Trigger.onUpdate(
                      onEvent: (event) async {
                        print('BEFORE: ${event.before}\n'
                            'AFTER: ${event.after}');
                        before = event.before;
                        after = event.after;
                        updateTriggered++;
                      },
                      beforeNeed: true,
                      afterNeed: true)
                ])
              ]),
          children: [RestAccessPoint('api')]), (tester) async {
    tester('/api/users', statusCodeIs(201),
        methods: Methods.POST, body: {'_id': 'user1', 'name': 'Mehmet'});
    test('triggered_create', () {
      expect(after, {'_id': 'user1', 'name': 'Mehmet'});
      expect(createTriggered, 1);
      expect(writeTriggered, 1);
    });


    tester('/api/users/user1', statusCodeIs(200),
        methods: Methods.PUT, body: {'name': 'Mehmet Yaz'});
    test('triggered_update', () {
      expect(before, {'_id': 'user1', 'name': 'Mehmet'});
      expect(after, {'_id': 'user1', 'name': 'Mehmet Yaz'});
      expect(updateTriggered, 1);
      expect(writeTriggered, 2);
    });




  });
}
