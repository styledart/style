import 'dart:io' as io;

import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
void main()  async {








  test("description", () {
    expect(() {
      var http = A();
      http.runtimeType;
    }, throwsA(isA<AssertionError>()));

    expect(() {
      var http = A<Http>();
      var ws = A<Ws>();
      var internal = A<Internal>();
      return http.isHttp && ws.isWs && internal.isInternal;
    }(), true);
  });
}

class A<T extends AgentMixin> {
  A() {
    assert(T == Http || T == Ws || T == Internal);
  }

  /// Http
  bool get isHttp => T == Http;

  /// Web Socket
  bool get isWs => T == Ws;

  /// Internal
  bool get isInternal => T == Internal;
}

///
mixin AgentMixin {}

///
mixin Http implements AgentMixin {}

///
mixin Ws implements AgentMixin {}

///
mixin Internal implements AgentMixin {}
