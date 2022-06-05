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

import 'dart:io';

import 'package:style_dart/style_dart.dart';
import 'package:style_test/style_test.dart';

void main() async {
  await initStyleTester('data_access', _MyServer(), (tester) async {
    /// Post
    /// Crete data with body
    tester(
        '/api/users',
        allOf(statusCodeIs(201),
            headerIs(HttpHeaders.locationHeader, equals('my_user1'))),
        methods: Methods.POST,
        body: {'_id': 'my_user1', 'name': 'Mehmet', 'l_name': 'Yaz'});

    /// Read data
    tester(
        '/api/users/my_user1',
        allOf(statusCodeIs(200),
            bodyIs({'_id': 'my_user1', 'name': 'Mehmet', 'l_name': 'Yaz'})),
        methods: Methods.GET);

    /// Create one more
    tester('/api/users', statusCodeIs(201),
        methods: Methods.POST,
        body: {'_id': 'my_user2', 'name': 'Jack', 'l_name': 'Daniel'});

    /// Read data
    tester(
        '/api/users/my_user2',
        allOf(statusCodeIs(200),
            bodyIs({'_id': 'my_user2', 'name': 'Jack', 'l_name': 'Daniel'})),
        methods: Methods.GET);

    /// Read list
    tester(
        '/api/users',
        allOf(bodyIs([
          {'_id': 'my_user1', 'name': 'Mehmet', 'l_name': 'Yaz'},
          {'_id': 'my_user2', 'name': 'Jack', 'l_name': 'Daniel'}
        ])),
        methods: Methods.GET);

    /// Update
    tester('api/users/my_user1', statusCodeIs(200),
        body: {'name': 'Mehmet1'}, methods: Methods.PUT);

    /// Check updated
    tester(
      '/api/users/my_user1',
      allOf(statusCodeIs(200),
          bodyIs({'_id': 'my_user1', 'name': 'Mehmet1', 'l_name': 'Yaz'})),
      methods: Methods.GET,
      description: 'my_user1_read2',
    );

    ///
    tester('/api/users/my_user1', statusCodeIs(200),
        description: 'my_user1_delete', methods: Methods.DELETE);
  });
}

class _MyServer extends StatelessComponent {
  const _MyServer({Key? key}) : super(key: key);

  @override
  Component build(BuildContext context) => Server(
        dataAccess: DataAccess(SimpleCacheDataAccess(),
            defaultPermission: false, collections: []),
        children: [RestAccessPoint('api')]);
}
