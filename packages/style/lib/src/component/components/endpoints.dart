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
      return (message as Request)
          .createResponse(body.data, statusCode: statusCode);
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
    } on Exception catch(e,s) {
      print("ERR WHERE: ${(context as Binding )._errorWhere}");
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
  final FutureOr<Message> Function(Request request) onRequest;

  @override
  FutureOr<Message> onCall(Request request) async {

      return await onRequest(request);

  }
}

///
class SimpleAccessPoint extends StatelessComponent {
  ///
  const SimpleAccessPoint({Key? key}) : super(key: key);

  @override
  Component build(BuildContext context) {
    return AccessPoint((request) {
      var req = (request as HttpStyleRequest);
      return Query(
          type: QueryType.delete,
          token: request.context.accessToken ?? "",
          // selectorBuilder: (req.path.notProcessedValues.isNotEmpty
          //     ? req.path.notProcessedValues.first
          //     : null),
          collection: req.currentPath);
    });
  }
}

/// TODO: Document
class AccessPoint extends Endpoint {
  ///
  AccessPoint(this.queryBuilder) : super();

  //TODO: Permission

  ///
  final FutureOr<Query> Function(Request request) queryBuilder;

  @override
  FutureOr<Message> onCall(Request request) async {
    var dataAccess = context.dataAccess;
    var base = (request as HttpStyleRequest).baseRequest;

    if (base.method == "POST") {
      var r = await dataAccess.create(await queryBuilder(request),
          (request.body as Map).cast<String, dynamic>());
      return request.createResponse(r);
    } else if (base.method == "GET") {
      var r = await dataAccess.read(await queryBuilder(request));
      return request.createResponse(r);
    } else if (base.method == "PUT" || base.method == "PATCH") {
      var r = await dataAccess.update(
          await queryBuilder(request), (request.body as Map<String, dynamic>));
      return request.createResponse(r);
    } else if (base.method == "DELETE") {
      var r = await dataAccess.delete(await queryBuilder(request));
      return request.createResponse(r);
    } else {
      throw MethodNotAllowedException();
    }
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
          print("Dir: $en");
        } else if (en is File) {
          var p = en.path
              .replaceFirst(component.directory, "")
              .replaceAll(Platform.pathSeparator, "/");
          docs[p] = en;
        }
        entities.removeAt(0);
      }
    }

    print("DOCS : $docs");

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
          print("Dir: $en");
        } else {
          print("Fil: $en");
        }
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
