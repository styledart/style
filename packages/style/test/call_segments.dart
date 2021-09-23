import 'package:style/src/style_base.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  var path = "/a/b/c";

  var controller = PathController(path);

  test("description", () {
    var p = controller.resolveFor([
      PathSegment("x"),
      PathSegment("y"),
      PathSegment("z"),
      PathSegment("a")
    ]);
    expect(
        p.segment,
        PathSegment("a"));



  });
}
