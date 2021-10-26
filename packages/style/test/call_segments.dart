import 'package:style_dart/style_dart.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  var path = "/a/b/c";

  var controller = PathController.fromFullPath(path);

  test("description", () {
    var p = controller.resolveFor([
      PathSegment("x"),
      PathSegment("y"),
      PathSegment("z"),
      PathSegment("a")
    ]);
    expect(p.segment, PathSegment("a"));
  });
}
