/*
 * Copyright (c) 2021. This code was written by Mehmet Yaz. Mehmet Yaz does not
 * accept the problems that may arise due to these codes.
 */

part of '../../style_base.dart';

///
class DefaultExceptionEndpoint<T extends Exception>
    extends ExceptionEndpoint<T> {
  @override
  FutureOr<Response> onError(
      Message message, T exception, StackTrace stackTrace) {
    var body = JsonBody({
      "exception": exception.toString(),
      "stack_trace": stackTrace.toString()
    });

    var statusCode = (exception is StyleException) ? exception.statusCode : 500;

    if (message is Response) {
      return message
        ..body = body
        ..statusCode = statusCode;
    } else {
      return (message as Request).response(body.data, statusCode: statusCode);
    }
  }
}

///
typedef ExceptionHandleEndpoint<T extends Exception> = FutureOr<Response>
    Function(Message request, T exception, StackTrace stackTrace);

///
abstract class ExceptionEndpoint<T extends Exception> extends Endpoint {
  ///
  FutureOr<Response> onError(
      Message message, T exception, StackTrace stackTrace);

  @override
  FutureOr<Message> onCall(Request request,
      [T? exception, StackTrace? stackTrace]) async {
    try {
      var e = await onError(request, exception!, stackTrace!);
      if (exception is StyleException) {
        e.statusCode = exception.statusCode;
      }
      return e;
    } on Exception {
      rethrow;
    }
  }

  @override
  ExceptionEndpointCallingBinding<T> createBinding() {
    return ExceptionEndpointCallingBinding<T>(this);
  }

  @override
  ExceptionEndpointCalling<T> createCalling(BuildContext context) {
    return ExceptionEndpointCalling<T>(
        context as ExceptionEndpointCallingBinding<T>);
  }
}

///
class SimpleExceptionEndpoint<T extends Exception>
    extends ExceptionEndpoint<T> {
  ///
  SimpleExceptionEndpoint(this.exceptionHandler);

  ///
  final ExceptionHandleEndpoint<T> exceptionHandler;

  @override
  FutureOr<Response> onError(
      Message message, T exception, StackTrace stackTrace) {
    return exceptionHandler(message, exception, stackTrace);
  }
}

///
class SimpleEndpoint extends Endpoint {
  ///
  SimpleEndpoint(this.onRequest);

  ///
  SimpleEndpoint.static(dynamic body) : onRequest = _static(body);

  static FutureOr<Response> Function(Request req) _static(dynamic body) {
    var _body = Body(body);
    return (req) {
      return req.response(_body);
    };
  }

  ///
  final FutureOr<Message> Function(Request request) onRequest;

  @override
  FutureOr<Message> onCall(Request request) async {
    return await onRequest(request);
  }
}

/// Access data with context's DataAccess
///
/// Supported Operations
///
///
///
/// ## Operations
/// ### Get
/// * read once : "/collection/identifier"
/// * read multiple: "/collection"
/// or "/collection/q?{query}"
///
///
/// ## Query
///
///
class SimpleAccessPoint extends StatelessComponent {
  ///
  const SimpleAccessPoint(this.route,
      {Key? key, this.identifierMapper = const <String, String>{}})
      : super(key: key);

  ///
  final String route;

  ///
  final Map<String, String> identifierMapper;

  ///
  Access _create(Request request) {
    try {
      return Access(
          type: AccessType.create,
          collection: request.path.current,
          data: (request.body?.data) as Map<String, dynamic>);
    } on Exception {
      rethrow;
    }
  }

  ///
  Access _read(Request request) {
    try {
      //TODO: check not processed is not empty
      return Access(
          type: AccessType.read,
          collection: request.path.current,
          identifier: request.path.notProcessedValues.first);
    } on Exception {
      rethrow;
    }
  }

  ///
  Access _readList(Request request) {
    try {
      return Access(
          type: AccessType.readMultiple, collection: request.path.current);
    } on Exception {
      rethrow;
    }
  }

  ///
  Access _update(Request request) {
    try {
      return Access(
          type: AccessType.update,
          collection: request.path.current,
          data: (request.body?.data) as Map<String, dynamic>);
    } on Exception {
      rethrow;
    }
  }

  ///
  Access _delete(Request request) {
    try {
      //TODO: check not processed is not empty
      return Access(
          type: AccessType.update,
          collection: request.path.current,
          identifier: request.path.notProcessedValues.first);
    } on Exception {
      rethrow;
    }
  }

  @override
  Component build(BuildContext context) {
    return Route(route, handleUnknownAsRoot: true,
        root: AccessPoint((request) async {
      var method = request.method;
      Access access;

      if (method == null) {
        throw MethodNotAllowedException();
      } else if (method == Methods.POST) {
        if (request.body is! JsonBody) {
          throw BadRequests();
        }
        access = _create(request);
      } else if (method == Methods.GET) {
        if (request.path.notProcessedValues.isEmpty) {
          access = _readList(request);
        } else {
          access = _read(request);
        }
      } else if (method == Methods.PUT || method == Methods.PATCH) {
        if (request.path.notProcessedValues.isEmpty) {
          throw UnimplementedError();
        } else {
          access = _update(request);
        }
      } else if (method == Methods.DELETE) {
        if (request.path.notProcessedValues.isEmpty) {
          throw UnimplementedError();
        } else {
          access = _delete(request);
        }
      } else {
        throw MethodNotAllowedException();
      }

      return AccessEvent(
        access: access,
        context: context,
        token: null,
        request: request,
      );
    }));
  }
}

/// TODO: Document
class AccessPoint extends Endpoint {
  ///
  AccessPoint(this.queryBuilder) : super();

  //TODO: Permission

  ///
  final FutureOr<AccessEvent> Function(Request request) queryBuilder;

  @override
  FutureOr<Message> onCall(Request request) async {
    var dataAccess = context.dataAccess;
    var acc = await queryBuilder(request);
    DbResult result;
    switch (acc.access.type) {
      case AccessType.read:
        result = ((await dataAccess.read(acc)));
        break;
      case AccessType.readMultiple:
        result = ((await dataAccess.readList(acc)));
        break;
      case AccessType.create:
        result = ((await dataAccess.create(acc)));
        break;
      case AccessType.update:
        result = ((await dataAccess.update(acc)));
        break;
      case AccessType.exists:
        result = ((await dataAccess.exists(acc)));
        break;
      case AccessType.listen:
        result = ((await dataAccess.listen(acc.access.query!)));
        break;
      case AccessType.delete:
        result = ((await dataAccess.delete(acc)));
        break;
      case AccessType.count:
        result = ((await dataAccess.count(acc)));
        break;
    }
    return request.response(result.data,
        headers: result.headers, statusCode: result.statusCode);
  }
}

///
class DocumentService extends StatefulEndpoint {
  ///
  DocumentService(this.directory, {this.cacheAll = true})
      : assert(directory.endsWith(Platform.pathSeparator));

  ///
  final String directory;

  ///
  final bool cacheAll;

  @override
  EndpointState<StatefulEndpoint> createState() =>
      DocumentServiceEndpointState();
}

///
class DocumentServiceEndpointState extends EndpointState<DocumentService> {
  ///
  Map<String, dynamic>? documents;

  Future<void> _loadDirectories() async {
    var docs = <String, File>{};

    var entities = <FileSystemEntity>[Directory(component.directory)];

    while (entities.isNotEmpty) {
      for (var en in List.from(entities)) {
        if (en is Directory) {
          entities.addAll(en.listSync());
        } else if (en is File) {
          var p = en.path
              .replaceFirst(component.directory, "")
              .replaceAll(Platform.pathSeparator, "/");
          docs[p] = en;
        }
        entities.removeAt(0);
      }
    }

    if (component.cacheAll) {
      var cachedDocs = <String, dynamic>{};
      for (var doc in docs.entries) {
        cachedDocs[doc.key] = await (doc.value).readAsString();
      }
      documents = cachedDocs;
    } else {
      documents = docs;
    }
  }

  ///
  late Future<void> loader;

  @override
  void initState() {
    loader = _loadDirectories();
    super.initState();
  }

  @override
  FutureOr<Message> onCall(Request request) async {
    if (documents == null) {
      await loader;
    }

    var not = request.path.notProcessedValues;

    var req = request.path.current +
        (not.isNotEmpty
            ? "/"
                "${not.join("/")}"
            : "");
    var base = (request as HttpStyleRequest).baseRequest;

    if (!documents!.containsKey(req)) {
      base.response.headers.contentType = ContentType.html;
      base.response.write("""
      <html>
      <body>
      <h1>404 Not Found</h1>
      <h5>
      Calling: $req
      Only available: ${documents!.keys.toList()}
      </h5>
      </body>
      </html>
      """);
      base.response.close();
    } else {
      String c;

      if (req.endsWith(".js")) {
        c = "text/javascript";
      } else if (req.endsWith(".css")) {
        c = "text/css";
      } else if (req.endsWith(".html")) {
        c = "text/html";
      } else if (req.endsWith(".dart")) {
        c = "text/dart";
      } else {
        c = "text/plain";
      }

      if (component.cacheAll) {
        base.response.headers.add(HttpHeaders.contentTypeHeader, c);
        base.response.write(documents![req]);
        base.response.close();
      } else {
        base.response.headers.add(HttpHeaders.contentTypeHeader, c);
        base.response.write((documents![req] as File).readAsStringSync());
        base.response.close();
      }
    }

    return NoResponseRequired(request: request);
  }
}

///
class Favicon extends StatefulEndpoint {
  ///
  Favicon(this.assetsPath);

  ///
  final String assetsPath;

  @override
  EndpointState createState() => FaviconState();
}

///
class FaviconState extends EndpointState<Favicon> {
  ///
  Uint8List? data;

  ///
  late Future<void> dataLoader;

  ///
  String? tag;

  ///
  String get faviconPath => "${component.assetsPath}"
      "${Platform.pathSeparator}favicon.ico";

  ///
  Future<void> _loadIcon() async {
    var entities = <FileSystemEntity>[Directory(component.assetsPath)];

    while (entities.isNotEmpty) {
      for (var en in List.from(entities)) {
        if (en is Directory) {
          entities.addAll(en.listSync());
        } else {}
        entities.removeAt(0);
      }
    }

    var file = File(faviconPath);
    data = await file.readAsBytes();
    tag = getRandomId(5);
  }

  ///
  void listenFileChanges() {
    Directory(component.assetsPath).watch().listen((event) {
      if (event.path == faviconPath && File(faviconPath).existsSync()) {
        data = null;
        dataLoader = _loadIcon();
      }
    });
  }

  @override
  void initState() {
    dataLoader = _loadIcon();
    listenFileChanges();
    super.initState();
  }

  @override
  FutureOr<Message> onCall(Request request) async {
    var base = (request as HttpStyleRequest).baseRequest;

    if (base.headers["if-none-match"] != null &&
        base.headers["if-none-match"] == tag) {
      base.response.statusCode = 304;
      base.response.contentLength = 0;
      base.response.close();
      return NoResponseRequired(request: request);
    }

    if (data == null) {
      await dataLoader;
    }

    base.response.contentLength = data!.length;
    base.response.headers
      ..add(HttpHeaders.contentTypeHeader, ContentType.binary.mimeType)
      ..add(HttpHeaders.cacheControlHeader, "must-revalidate")
      ..add(HttpHeaders.etagHeader, tag!);
    base.response.add(data!);
    base.response.close();
    return NoResponseRequired(request: request);
  }
}

/// Always throw
class Throw extends SimpleEndpoint {

  /// Construct exception
  Throw(Exception exception) : super((re) => throw exception);
}
