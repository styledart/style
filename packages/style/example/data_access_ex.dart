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

import 'dart:async';

import 'package:style_dart/style_dart.dart';
import 'package:style_test/style_test.dart';

void main() async {
  var bind = runService(_MyServer());

  var calling = bind.findCalling.calling;

  var res = await calling(TestRequest(
      agent: Agent.http,
      cause: Cause.clientRequest,
      methods: Methods.POST,
      path: '/test',
      body: {'_id': 'my_user1', 'name': 'Mehmet', 'l_name': 'Yaz'}));

  print((res as Response).statusCode);
}

class _MyServer extends StatelessComponent {
  const _MyServer({Key? key}) : super(key: key);

  @override
  Component build(BuildContext context) => Server(
      dataAccess: DataAccess<CommonLanguage>(SimpleCacheDataAccess()),
      children: [Route('test', root: AccessEndp())]);
}

/// TODO: Document
class AccessEndp extends Endpoint {
  AccessEndp() : super();

  @override
  FutureOr<Object> onCall(Request request) => CommonAccess(
      type: AccessType.create,
      collection: 'users',
      create: CommonCreate(
          (request.body as JsonBody).data as Map<String, dynamic>));
/*AccessEvent<CommonLanguage>(
      access: CommonAccess(
          type: AccessType.create,
          collection: 'users',
          create: CommonCreate(
              (request.body as JsonBody).data as Map<String, dynamic>)),
      request: request);*/
}
