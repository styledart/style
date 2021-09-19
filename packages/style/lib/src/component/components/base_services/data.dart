part of '../../run.dart';

class DataAccess extends StatefulComponent {
  const DataAccess(
      {GlobalKey? key,
      required this.child,
      required this.dataAccessHandler})
      : super(key: key);
  final Component child;
  final DataAccessHandler dataAccessHandler;

  @override
  DataAccessState createState() => DataAccessState();

  @override
  StatefulBinding createBinding() =>
      _BaseServiceStatefulBinding(this);
}

class DataAccessState extends State<DataAccess> {
  static DataAccessState of(BuildContext context) {
    return context.dataAccess;
    // return context.owner._states[context.owner.dataAccess]!.state
    //     as DataAccessState;
  }

  @override
  Component build(BuildContext context) {
    return component.child;
  }
}

abstract class DataAccessHandler {
  const DataAccessHandler();
//TODO:
}

class DefaultDataAccessHandler extends DataAccessHandler {}
