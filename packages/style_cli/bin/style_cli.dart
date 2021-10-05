import 'dart:isolate';

void main(List<String> arguments) async {
  var receivePort = ReceivePort();

  var isolate = await Isolate.spawnUri(
      Uri.parse("D:/style/packages/style_cli/bin/other.dart"),
      [],
      receivePort.sendPort);

  receivePort.listen((message) {
    print("Geri Geldi: $message");

  });

  print(isolate.controlPort);

  var i = 0;
  while (i < 10) {
    receivePort.sendPort.send("message $i");

    await Future.delayed(Duration(seconds: 3));
    i++;
  }




  // var current = Directory.current.path;
  // if (arguments.isEmpty) throw 0;
  // var process = await Process.start("dart", arguments,workingDirectory: current);
  //
  //
  // process.stderr.listen((event) {
  //   print(utf8.decode(event));
  // });
  //
  // await for (var event in process.stdout) {
  //   print(utf8.decode(event));
  // }
  //
  //
  //
  //
  //
  // var ex = await process.exitCode;
  //
  //
  // ReceivePort().listen((message) {
  //
  // });
  //
  // print(ex);
}
