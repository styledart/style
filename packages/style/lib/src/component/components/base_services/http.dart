part of '../../../style_base.dart';
abstract class HttpServiceHandler {
  //TODO:
  const HttpServiceHandler();

  final String address = "http://localhost:9090";
}

class DefaultHttpServiceHandler extends HttpServiceHandler {
}

class HttpService extends StatefulComponent {
  const HttpService(
      {GlobalKey? key,
      required this.httpServiceHandler,
      required this.child})
      : super(key: key);
  final Component child;
  final HttpServiceHandler httpServiceHandler;

  @override
  HttpServiceState createState() => HttpServiceState();

  @override
  StatefulBinding createBinding() =>
      _BaseServiceStatefulBinding(this);
}

class HttpServiceState extends State<HttpService> {
  static HttpServiceState of(BuildContext context) {
    return context
        .owner
        ._states[context.owner._httpServiceKey]!
        .state as HttpServiceState;
  }

  @override
  Component build(BuildContext context) {
    return component.child;
  }
}
