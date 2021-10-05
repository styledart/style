part of '../../style_base.dart';

///
enum QueryType {
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
}

///
abstract class Query {
  ///
  Query._(
      {required this.collection,
      required this.token,
      required this.queryType,
      this.documentId,
      this.query,
      this.fields,
      this.filter,
      this.limit,
      this.offset,
      this.sort,
      this.document});

  ///
  factory Query(
      {required QueryType type,
      required String collection,
      required String token,
      Map<String, dynamic>? document,
      String? documentId,
      Map<String, dynamic>? query,
      Map<String, dynamic>? fields,
      Map<String, dynamic>? filter,
      int? limit,
      int? offset,
      Map<String, dynamic>? sort}) {
    switch (type) {
      case QueryType.read:
        // TODO: Handle this case.
        break;
      case QueryType.readMultiple:
        // TODO: Handle this case.
        break;
      case QueryType.create:
        return CreateQuery(
          document: document!,
          collection: collection,
          token: token,
        );
      case QueryType.update:
        // TODO: Handle this case.
        break;
      case QueryType.exists:
        // TODO: Handle this case.
        break;
      case QueryType.listen:
        // TODO: Handle this case.
        break;
      case QueryType.delete:
        // TODO: Handle this case.
        break;
      case QueryType.count:
        // TODO: Handle this case.
        break;
    }

    throw 0;
  }

  ///
  final String collection;

  ///
  final QueryType queryType;

  ///
  String? documentId;

  ///
  String? token;

  ///
  Map<String, dynamic>? query, filter, sort, fields, document;

  ///
  int? limit, offset;

  ///
  dynamic build() {}
}

///
class CreateQuery extends Query {
  ///
  CreateQuery(
      {required String collection,
      required String token,
      required Map<String, dynamic> document,
      String? documentId})
      : super._(
            queryType: QueryType.create,
            collection: collection,
            token: token,
            documentId: documentId,
            document: document);

  ///
  @override
  Map<String, dynamic> build() {
    // TODO: implement build
    throw UnimplementedError();
  }
}
