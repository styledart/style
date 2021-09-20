part of '../style_base.dart';

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

  var results = <String>[];
  binding.visitCallingChildren(TreeVisitor((binding) {
    if (binding.currentValue is EndpointCalling) {
      results.add(
          "%${(binding.currentValue.binding as EndpointCallingBinding).fullPath} %");
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
    return Gateway(children: {"media": Media(), "picture": Picture()});
  }
}

class Media extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    print("in media: ${context.owner}");
    return Gateway(children: {"picture": Picture(), "video": Video()});
  }
}

class Picture extends Endpoint {
  Picture() : super();

  @override
  FutureOr<void> onCall(Request request) {
    throw UnimplementedError();
  }
}

class Video extends Endpoint {
  Video() : super();

  @override
  FutureOr<void> onCall(Request request) {
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
