part of '../../../style_base.dart';

abstract class SocketServiceHandler {
  //TODO:
  const SocketServiceHandler();
}

class DefaultSocketServiceHandler
    extends SocketServiceHandler {}

class SocketService extends StatefulComponent {
  const SocketService(
      {GlobalKey? key,
      required this.child,
      required this.socketServiceHandler})
      : super(key: key);
  final Component child;
  final SocketServiceHandler socketServiceHandler;

  @override
  SocketServiceState createState() => SocketServiceState();

  @override
  StatefulBinding createBinding() =>
      _BaseServiceStatefulBinding(this);
}

class SocketServiceState extends State<SocketService> {
  static SocketServiceState of(BuildContext context) {
    return context
        .owner
        ._states[context.owner._socketServiceKey]!
        .state as SocketServiceState;
  }

  @override
  Component build(BuildContext context) {
    return component.child;
  }
}
