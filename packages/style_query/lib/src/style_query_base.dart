import 'package:meta/meta.dart';

import 'access_language.dart';
import 'create.dart';
import 'pipeline.dart';
import 'query.dart';
import 'settings.dart';
import 'update.dart';

///
typedef JsonMap = Map<String, dynamic>;

///
enum AccessType {
  ///
  read,

  ///
  readMultiple,

  ///
  create,

  ///
  update,

  ///
  exists,

  ///
  listen,

  ///
  delete,

  ///
  count,

  ///
  aggregation
}

/// A request to access the database / a collection in the database.
/// Any CRUD operations, aggregations,
/// or other operations are defined as [Access].
///
@immutable
class Access<L extends AccessLanguage> {
  ///
  const Access(
      {this.query,
      required this.type,
      this.create,
      this.update,
      required this.collection,
      this.pipeline,
      this.settings});

  /// Access language
  Type get language => L;

  ///
  final Query<L>? query;

  ///
  final Pipeline<L>? pipeline;

  ///
  final OperationSettings? settings;

  ///
  final AccessType type;

  ///
  final String collection;

  ///
  final CreateData<L>? create;

  ///
  final UpdateData<L>? update;

  ///
  JsonMap toMap() => {
        "collection": collection,
        "type": type.index,
        if (create != null) "create": create!.toMap(),
        if (update != null) "update": update!.toMap(),
        if (pipeline != null) "pipeline": pipeline!.toMap(),
        if (query != null) "query": query!.toMap(),
      };
}
