import 'dart:isolate';

void main() {
  var port = RawReceivePort();

  port.handler = (m) {
    print(m);
    port.sendPort.send(m);
  };
}
