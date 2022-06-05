/*
 * Copyright 2021 styledart.dev - Mehmet Yaz
 *
 * Licensed under the GNU AFFERO GENERAL PUBLIC LICENSE,
 *    Version 3 (the "License");
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

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:style_dart/style_dart.dart';

import '../test/services/auth_test.dart';

void main() async {
  var binding = runService(MyServer());

  await binding.httpService.ensureInitialize();
  await binding.socketService.ensureInitialize();

  var client = HttpClient();

  var req = await client.getUrl(Uri.parse('http://localhost/test'));

  var res = await req.close();

  var bytes = Uint8List.fromList([for (var l in await res.toList()) ...l]);

  print(utf8.decode(bytes));

  var wsClient = await WebSocket.connect('ws://localhost/ws');

  wsClient.listen((event) {
    print('From ws : $event');
  });

  wsClient.add(json.encode({'id': 'id_1', 'path': '/test'}));
}

class MyServer extends StatelessComponent {
  @override
  Component build(BuildContext context) => Server(
          httpService: DefaultHttpServiceHandler(host: 'localhost', port: 80),
          cryptoService: MyEncHandler(
              tokenKey1: '11111111111111111111111111111111',
              tokenKey2: '11111111111111111111111111111111',
              tokenKey3: '11111111111111111111111111111111'),
          socketService: BasicWebSocketService(),
          children: [
            Builder(builder: (c) => WebSocketService.of(c).component(c)),
            Route('test',
                root: SimpleEndpoint((request, context) => Stream.periodic(
                      Duration(milliseconds: 150),
                      (computationCount) => {'hello': 'world'},
                    ).take(10))),
          ]);
}
