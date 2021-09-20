part of '../../../style_base.dart';

class CryptoComponent extends StatefulComponent {
  const CryptoComponent(
      {GlobalKey? key,
      required this.cryptoHandler,
      required this.child})
      : super(key: key);

  final Component child;
  final CryptoHandler cryptoHandler;

  @override
  CryptoState createState() => CryptoState();

  @override
  StatefulBinding createBinding() =>
      _BaseServiceStatefulBinding(this);
}

class CryptoState extends State<CryptoComponent> {
  static CryptoState of(BuildContext context) {
    return context
        .owner
        ._states[context.owner._cryptoServiceKey]!
        .state as CryptoState;
  }

  @override
  Component build(BuildContext context) {
    return component.child;
  }
}

abstract class CryptoHandler {
  const CryptoHandler();

  String encryptFirstStage(String plain);
}

class DefaultCryptoHandler extends CryptoHandler {
  @override
  String encryptFirstStage(String plain) {
    throw UnimplementedError();
  }
}
