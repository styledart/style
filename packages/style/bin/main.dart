import 'dart:io' as io;

void main() async {
  var server = await io.HttpServer.bind("localhost", 9090);
  var server2 = await io.HttpServer.bind("localhost", 9091);

  server2.listen((event) {
    event.response.write("from 2");
    print(event.cookies);
    event.response.close();
  });

  await for (var req in server) {
    req.response.statusCode = 303;
    print(req.cookies);
    req.response.headers.add("location", "http://localhost:9091");
    req.response.close();
  }
}
