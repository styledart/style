part of '../../style_base.dart';

///
class AccessEvent {
  ///
  AccessEvent(
      {required this.access,
      required this.context,
      this.token,
      required this.request})
      : createTime = DateTime.now(),
        type = _getDbOpType(access.type);

  ///
  static DbOperationType _getDbOpType(AccessType type) {
    switch (type) {
      case AccessType.read:
        return DbOperationType.read;
      case AccessType.readMultiple:
        return DbOperationType.read;
      case AccessType.create:
        return DbOperationType.create;
      case AccessType.update:
        return DbOperationType.update;
      case AccessType.exists:
        return DbOperationType.read;
      case AccessType.listen:
        return DbOperationType.read;
      case AccessType.delete:
        return DbOperationType.delete;
      case AccessType.count:
        return DbOperationType.read;
    }
  }

  ///
  Access access;

  ///
  final AccessToken? token;

  ///
  DbOperationType type;

  ///
  Request request;

  ///
  BuildContext context;

  ///
  final DateTime createTime;

  ///
  Map<String, dynamic>? before, after;
}
