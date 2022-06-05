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

import 'package:json_schema2/json_schema2.dart';
import 'package:style_dart/style_dart.dart';
import 'package:style_test/style_test.dart';

void main() async {
  ///
  await initStyleTester('permission_test', _MyServer(), (tester) async {
    /// fail (name doesn't exists)
    tester('/api/users', statusCodeIs(403),
        methods: Methods.POST,
        body: {'id': 'user1', 'birth_date': 1995, 'updatable': true});

    /// fail (additionalProperties exists)
    tester('/api/users', statusCodeIs(403), methods: Methods.POST, body: {
      'id': 'user1',
      'name': 'Mehmet',
      'birth_date': 1995,
      'updatable': true,
      'foo': 'bar'
    });

    /// success
    tester('/api/users', statusCodeIs(201), methods: Methods.POST, body: {
      'id': 'user1',
      'name': 'Mehmet',
      'birth_date': 1995,
      'updatable': true,
    });

    /// success
    tester('/api/users', statusCodeIs(201), methods: Methods.POST, body: {
      'id': 'user2',
      'name': 'John',
      'birth_date': 2000,
      'updatable': false,
    });

    /// update fail (birth_date updated)
    tester('/api/users/user1', statusCodeIs(403),
        description: 'user1_bd_update_fail',
        methods: Methods.PUT,
        body: {
          'birth_date': 1996,
        });

    /// update fail ("updatable" updated)
    tester('/api/users/user1', statusCodeIs(403),
        description: 'user1_u_update_fail',
        methods: Methods.PUT,
        body: {
          'updatable': false,
        });

    /// update fail ("updatable" updated)
    tester('/api/users/user1', statusCodeIs(200),
        description: 'user1_update_s',
        methods: Methods.PUT,
        body: {'additional_info': 'hello'});

    /// update fail ("updatable" updated)
    tester('/api/users/user2', statusCodeIs(403),
        description: 'user2_update_fail',
        methods: Methods.PUT,
        body: {'additional_info': 'hello'});
  });
}

class _MyServer extends StatelessComponent {
  const _MyServer({Key? key}) : super(key: key);

  @override
  Component build(BuildContext context) => Server(
        dataAccess: DataAccess(SimpleCacheDataAccess(),
            defaultPermission: false,
            collections: [
              DbCollection('users',
                  identifier: 'id',
                  createSchema: userCreateSchema,
                  resourceSchemaOnUpdate: onUpdateResource,
                  updateSchema: userUpdateSchema),
            ]),
        children: [RestAccessPoint('api')]);
}

///
JsonSchema userCreateSchema = JsonSchema.createSchema({
  'required': ['id', 'name', 'birth_date'],
  'additionalProperties': false,
  'properties': {
    'id': {'type': 'string'},
    'name': {'type': 'string'},
    'birth_date': {'type': 'integer'},
    'updatable': {'type': 'boolean'}
  }
});

///
JsonSchema userUpdateSchema = JsonSchema.createSchema({
  'additionalProperties': false,
  'required': <String>[],
  'properties': {
    'additional_info': {'type': 'string'}
  }
});

///
JsonSchema onUpdateResource = JsonSchema.createSchema({
  '\$comment': 'updatable is must not null or false',
  'required': ['updatable'],
  'properties': {
    'updatable': {
      'enum': [true]
    }
  },
  'additionalProperties': true
});
