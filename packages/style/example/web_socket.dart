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
