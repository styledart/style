import 'dart:async';

import 'package:meta/meta.dart';
import 'package:style_interface/style_interface.dart';
part 'calling.dart';

part 'component_base.dart';

part 'components/base_services/base.dart';

part 'components/base_services/crypto.dart';

part 'components/base_services/data.dart';

part 'components/base_services/http.dart';

part 'components/base_services/web_socket.dart';

part 'components/calling_component.dart';

part 'components/enpoint.dart';

part 'components/gateway.dart';

part 'components/path_router.dart';

part 'components/path_segment.dart';

part 'components/service.dart';

part 'context.dart';

void main() {
  runService(MyServer());
}

void runService(Component component) {
  var binding = component.createBinding();
  binding._build();
  print("Build End");

  binding.visitChildren(TreeVisitor((visitor) {
    print(visitor.currentValue.component);
  }));

  List<String> results = [];
  var visiting = binding.visitCallingChildren(TreeVisitor((binding) {
    if (binding.currentValue is EndpointCalling) {
      results.add(
          "% ${(binding.currentValue.binding as EndpointCallingBinding).fullPath} %");
    }
  }));

  print(results.join("\n"));

  // var visiting = binding.visitChildren(TreeVisitor((binding) {
  //   print(binding.currentValue);
  // }));
  //
  // print(visiting.result);
  // var service = binding.findChildState<_Sort>();
  //
  // print(service);
}

class MyServer extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    print("in server: ${context.component}");
    return Server(
        rootName: "my_server",
        children: {"lang": Language(), "user": User(), "media": Media()},
        rootEndpoint: UnknownEndpoint());
  }
}

class Language extends StatelessComponent {
  const Language({Key? key}) : super(key: key);

  @override
  Component build(BuildContext context) {
    return UnknownEndpoint();
  }
}

class User extends StatelessComponent {
  const User({Key? key}) : super(key: key);

  @override
  Component build(BuildContext context) {
    print("in users: ${context.owner}");
    return Gateway(children: {
      "media" : Media(),
      "picture" : Picture()
    });
  }
}

class Media extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    print("in media: ${context.owner}");
    return Gateway(children: {});
  }
}

class Picture extends Endpoint {
  Picture() : super();

  @override
  FutureOr<void> onCall(StyleRequest request) {
    throw UnimplementedError();
  }
}

class Video extends Endpoint {
  Video() : super();

  @override
  FutureOr<void> onCall(StyleRequest request) {
    throw UnimplementedError();
  }
}

class Post extends StatefulComponent {
  const Post({GlobalKey? key}) : super(key: key);

  @override
  PostState createState() => PostState();
}

class PostState extends State<Post> {
  @override
  Component build(BuildContext context) {
    return Gateway(children: {});
  }
}
