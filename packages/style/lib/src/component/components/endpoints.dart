/*
 * Copyright 2021 styledart.dev - Mehmet Yaz
 *
 * Licensed under the GNU AFFERO GENERAL PUBLIC LICENSE,
 *    Version 3 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       https://www.gnu.org/licenses/agpl-3.0.en.html
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

part of '../../style_base.dart';

///
class DefaultExceptionEndpoint<T extends Exception>
    extends ExceptionEndpoint<T> {
  @override
  FutureOr<Response> onError(
      Message message, T exception, StackTrace stackTrace) {
    var body = JsonBody({
      'exception': exception.toString(),
      'stack_trace': stackTrace.toString()
    });

    var statusCode = (exception is StyleException) ? exception.statusCode : 500;

    if (message is Response) {
      return message
        ..body = body
        ..statusCode = statusCode;
    } else {
      return (message as Request).response(body, statusCode: statusCode);
    }
  }
}

///
typedef ExceptionHandleEndpoint<T extends Exception> = FutureOr<Response>
    Function(Message request, T exception, StackTrace stackTrace);

///
abstract class ExceptionEndpoint<T extends Exception> extends Endpoint {
  ///
  FutureOr<Object> onError(Message message, T exception, StackTrace stackTrace);

  @override
  FutureOr<Message> onCall(Request request,
      [T? exception, StackTrace? stackTrace]) async {
    try {
      //TODO: Change
      var e = await onError(request, exception!, stackTrace!);
      if (e is Response) {
        if (exception is StyleException) {
          e.statusCode = exception.statusCode;
        }
        return e;
      } else {
        //
        if (e is Future) {
          var r = await e;
          if (r is Message) {
            return r;
          } else {
            return request.response(Body(r));
          }
        }
        if (e is Message) {
          return e;
        } else {
          return request.response(Body(e));
        }
      }
    } on Exception {
      rethrow;
    }
  }

  @override
  ExceptionEndpointCallingBinding<T> createBinding() =>
      ExceptionEndpointCallingBinding<T>(this);

  @override
  ExceptionEndpointCalling<T> createCalling(BuildContext context) =>
      ExceptionEndpointCalling<T>(
          context as ExceptionEndpointCallingBinding<T>);
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
          Message message, T exception, StackTrace stackTrace) =>
      exceptionHandler(message, exception, stackTrace);
}

///
class SimpleEndpoint extends Endpoint {
  ///
  SimpleEndpoint(this.onRequest, {EndpointPreferredType? preferredType})
      : _preferredType = preferredType;

  final EndpointPreferredType? _preferredType;

  @override
  EndpointPreferredType? get preferredType => _preferredType;

  ///
  SimpleEndpoint.static(Object body)
      : _preferredType = _type(body),
        onRequest = _static(body);

  static EndpointPreferredType? _type(Object body) {
    if (body is Message || body is Future<Message>) {
      return EndpointPreferredType.response;
    } else if (body is Body || body is Future<Body>) {
      return EndpointPreferredType.body;
    } else if (body is AccessEvent || body is Future<AccessEvent>) {
      return EndpointPreferredType.accessEvent;
    } else if (body is DbResult || body is Future<DbResult>) {
      return EndpointPreferredType.dbResult;
    } else {
      return EndpointPreferredType.anyEncodable;
    }
  }

  static FutureOr<Object> Function(Request req, BuildContext _) _static(
          Object body) =>
      (req, _) => (body);

  ///
  final FutureOr<Object> Function(Request request, BuildContext context)
      onRequest;

  @override
  FutureOr<Object> onCall(Request request) => onRequest(request, context);
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
class RestAccessPoint extends StatelessComponent {
  ///
  RestAccessPoint(this.route, {this.queryBuilder, Key? key}) : super(key: key);

  ///
  final String route;

  ///
  final CommonQuery Function(Map<String, String> queryParameters)? queryBuilder;

  ///
  final RandomGenerator randomIdentifier = RandomGenerator('[*#]/l(30)');

  ///
  Access _create(Request request, BuildContext context) {
    try {
      var col = request.path.next;
      var identifierKey = context.dataAccess.identifierMapping?[col] ?? '_sid';
      var body = (request.body?.data) as Map<String, dynamic>;
      String identifier;
      if (body.containsKey(identifierKey)) {
        identifier = body[identifierKey] as String;
      } else {
        identifier = randomIdentifier.generateString();
        body[identifierKey] = identifier;
      }
      return CommonAccess(
          type: AccessType.create, collection: col, create: CommonCreate(body));
    } on Exception {
      rethrow;
    }
  }

  ///
  Access _read(Request request) {
    try {
      //TODO: check not processed is not empty
      return CommonAccess(
        type: AccessType.read,
        collection: request.path.next,
        query: CommonQuery(id: request.path.notProcessedValues.first),
      );
    } on Exception {
      rethrow;
    }
  }

  ///
  Access _readList(Request request) {
    try {
      return CommonAccess(
          type: AccessType.readMultiple,
          collection: request.path.next,
          query: queryBuilder?.call(request.path.queryParameters) ??
              CommonQuery.fromMap(request.path.queryParameters['q'] != null
                  ? (json.decode(request.path.queryParameters['q']!)
                      as Map<String, dynamic>)
                  : () {
                      throw Exception();
                    }()));
    } on Exception {
      rethrow;
    }
  }

  ///
  Access _update(Request request) {
    try {
      return CommonAccess(
          type: AccessType.update,
          collection: request.path.next,
          query: CommonQuery(id: request.path.notProcessedValues.first),
          update: CommonUpdate((request.body?.data) as Map<String, dynamic>));
    } on Exception {
      rethrow;
    }
  }

  ///
  Access _delete(Request request) {
    try {
      //TODO: check not processed is not empty
      return CommonAccess(
        type: AccessType.delete,
        collection: request.path.next,
        query: CommonQuery(id: request.path.notProcessedValues.first),
      );
    } on Exception {
      rethrow;
    }
  }

  @override
  Component build(BuildContext context) {
    var result = AccessPoint((request, ctx) async {
      var method = request.method;
      Access access;

      if (method == null) {
        throw MethodNotAllowedException();
      } else if (method == Methods.POST) {
        if (request.body is! JsonBody) {
          throw BadRequests();
        }
        access = _create(request, ctx);
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
        request: request,
      );
    });
    return Route(route, handleUnknownAsRoot: true, root: result);
  }
}

/// TODO: Document
class AccessPoint extends Endpoint {
  ///
  AccessPoint(this.accessBuilder) : super();

  ///
  final FutureOr<AccessEvent> Function(Request request, BuildContext context)
      accessBuilder;

  @override
  EndpointPreferredType? get preferredType => EndpointPreferredType.accessEvent;

  @override
  FutureOr<AccessEvent> onCall(Request request) async {
    // var dataAccess = context.dataAccess;
    var acc = await accessBuilder(request, context);
    acc.context = context;
    // DbResult result;
    //
    return acc;

    // switch (acc.access.type) {
    //   case AccessType.read:
    //     result = ((await dataAccess.read(acc)));
    //     break;
    //   case AccessType.readMultiple:
    //     result = ((await dataAccess.readList(acc)));
    //     break;
    //   case AccessType.create:
    //     result = ((await dataAccess.create(acc)));
    //     break;
    //   case AccessType.update:
    //     result = ((await dataAccess.update(acc)));
    //     break;
    //   case AccessType.exists:
    //     result = ((await dataAccess.exists(acc)));
    //     break;
    //   case AccessType.listen:
    //     throw UnimplementedError();
    //   case AccessType.delete:
    //     result = ((await dataAccess.delete(acc)));
    //     break;
    //   case AccessType.count:
    //     result = ((await dataAccess.count(acc)));
    //     break;
    //   case AccessType.aggregation:
    //     result = await dataAccess.aggregation(acc);
    //     break;
    // }
    // return request.response(result.data,
    //     headers: result.headers, statusCode: result.statusCode);
  }
}

///
class ContentDelivery extends StatelessComponent {
  ///
  ContentDelivery(String directory,
      {this.useWatch = true,
      this.cacheFiles = true,
      this.useLastModified = true,
      this.beforeLoad,
      this.additional = const {}})
      : directory = directory.replaceAll('\\', '/');

  ///
  final String directory;

  ///
  final Map<String, Uint8List> additional;

  ///
  final bool cacheFiles;

  ///
  final bool useWatch;

  ///
  final bool useLastModified;

  ///
  final Future Function()? beforeLoad;

  @override
  Component build(BuildContext context) {
    Component res;

    // var add =
    //     additional.map((key, value) => MapEntry("$directory/$key", value));

    if (cacheFiles) {
      if (useLastModified) {
        res = _CachedContentDeliveryWithLastModified(
            _cacheFiles(directory, beforeLoad), directory,
            additional: additional, before: beforeLoad, watch: useWatch);
      } else {
        res = _CachedContentDelivery(
            _cacheFiles(directory, beforeLoad), directory,
            additional: additional, before: beforeLoad, watch: useWatch);
      }
    } else {
      if (useLastModified) {
        res = _ContentDeliveryWithLastModified(directory);
      } else {
        res = _ContentDelivery(directory);
      }
    }

    res = Route(_firstSegment, root: res, handleUnknownAsRoot: true);
    if (useLastModified) {
      return Gate(
          child: CacheControl(
            child: res,
            revalidation: Revalidation.mustRevalidate(IfModifiedSinceMethod()),
          ),
          onRequest: (r) => r..body = Body<String>(_filePath(r)));
    }
    return Gate(
        child: res,
        onRequest: (r) {
          var f = _filePath(r);
          return r..body = Body<String>(f);
        });
  }

  static final String _firstSegment = '{first}';
  static final String _f = 'first';

  String _filePath(Request request) {
    var not = request.path.notProcessedValues;

    var req = directory + request.path.arguments[_f]!;

    if (request.nextPathSegment != _firstSegment) {
      req += '/${request.nextPathSegment}';
    }
    if (not.isNotEmpty) {
      req += "/${not.join("/")}";
    }
    return req;
  }

  ///
  static List<File> _getFiles(String directory) {
    var docs = <File>[];

    var entities = <FileSystemEntity>[Directory(directory)];

    while (entities.isNotEmpty) {
      for (var en in List<FileSystemEntity>.from(entities)) {
        if (en is Directory) {
          entities.addAll(en.listSync());
        } else if (en is File) {
          docs.add(en);
        }
        entities.removeAt(0);
      }
    }
    return docs;
  }

  ///
  static Future<Stream<FileSystemEvent>> _watch(
      String directory, Future Function()? before) async {
    await (before)?.call();
    return Directory(directory).watch();
  }

  ///
  static Future<Map<String, CachedFile>> _cacheFiles(
      String directory, Future Function()? before) async {
    await (before)?.call();
    var cachedDocs = <String, CachedFile>{};
    for (var doc in _getFiles(directory)) {
      cachedDocs[doc.path.replaceAll('\\', '/')] = CachedFile(
          doc.path, await (doc).readAsBytes(), doc.lastModifiedSync());
    }
    return cachedDocs;
  }

  ///
  static final Map<String, ContentType> _contentTypes = {
    'xml': ContentType('application', 'xml', charset: 'utf-8'),
    'json': ContentType('application', 'json', charset: 'utf-8'),
    'evy': ContentType('application', 'envoy', charset: 'utf-8'),
    'fif': ContentType('application', 'fractals', charset: 'utf-8'),
    'spl': ContentType('application', 'futuresplash', charset: 'utf-8'),
    'hta': ContentType('application', 'hta', charset: 'utf-8'),
    'acx': ContentType('application', 'internet-property-stream',
        charset: 'utf-8'),
    'hqx': ContentType('application', 'mac-binhex40', charset: 'utf-8'),
    'doc': ContentType('application', 'msword', charset: 'utf-8'),
    'dot': ContentType('application', 'msword', charset: 'utf-8'),
    '*': ContentType('application', 'octet-stream', charset: 'utf-8'),
    'bin': ContentType('application', 'octet-stream', charset: 'utf-8'),
    'class': ContentType('application', 'octet-stream', charset: 'utf-8'),
    'dms': ContentType('application', 'octet-stream', charset: 'utf-8'),
    'exe': ContentType('application', 'octet-stream', charset: 'utf-8'),
    'lha': ContentType('application', 'octet-stream', charset: 'utf-8'),
    'lzh': ContentType('application', 'octet-stream', charset: 'utf-8'),
    'oda': ContentType('application', 'oda', charset: 'utf-8'),
    'axs': ContentType('application', 'olescript', charset: 'utf-8'),
    'pdf': ContentType('application', 'pdf', charset: 'utf-8'),
    'prf': ContentType('application', 'pics-rules', charset: 'utf-8'),
    'p10': ContentType('application', 'pkcs10', charset: 'utf-8'),
    'crl': ContentType('application', 'pkix-crl', charset: 'utf-8'),
    'ai': ContentType('application', 'postscript', charset: 'utf-8'),
    'eps': ContentType('application', 'postscript', charset: 'utf-8'),
    'ps': ContentType('application', 'postscript', charset: 'utf-8'),
    'rtf': ContentType('application', 'rtf', charset: 'utf-8'),
    'setpay':
        ContentType('application', 'set-payment-initiation', charset: 'utf-8'),
    'setreg': ContentType('application', 'set-registration-initiation',
        charset: 'utf-8'),
    'xla': ContentType('application', 'vnd.ms-excel', charset: 'utf-8'),
    'xlc': ContentType('application', 'vnd.ms-excel', charset: 'utf-8'),
    'xlm': ContentType('application', 'vnd.ms-excel', charset: 'utf-8'),
    'xls': ContentType('application', 'vnd.ms-excel', charset: 'utf-8'),
    'xlt': ContentType('application', 'vnd.ms-excel', charset: 'utf-8'),
    'xlw': ContentType('application', 'vnd.ms-excel', charset: 'utf-8'),
    'msg': ContentType('application', 'vnd.ms-outlook', charset: 'utf-8'),
    'sst': ContentType('application', 'vnd.ms-pkicertstore', charset: 'utf-8'),
    'cat': ContentType('application', 'vnd.ms-pkiseccat', charset: 'utf-8'),
    'stl': ContentType('application', 'vnd.ms-pkistl', charset: 'utf-8'),
    'pot': ContentType('application', 'vnd.ms-powerpoint', charset: 'utf-8'),
    'pps': ContentType('application', 'vnd.ms-powerpoint', charset: 'utf-8'),
    'ppt': ContentType('application', 'vnd.ms-powerpoint', charset: 'utf-8'),
    'mpp': ContentType('application', 'vnd.ms-project', charset: 'utf-8'),
    'wcm': ContentType('application', 'vnd.ms-works', charset: 'utf-8'),
    'wdb': ContentType('application', 'vnd.ms-works', charset: 'utf-8'),
    'wks': ContentType('application', 'vnd.ms-works', charset: 'utf-8'),
    'wps': ContentType('application', 'vnd.ms-works', charset: 'utf-8'),
    'hlp': ContentType('application', 'winhlp', charset: 'utf-8'),
    'bcpio': ContentType('application', 'x-bcpio', charset: 'utf-8'),
    'cdf': ContentType('application', 'x-netcdf', charset: 'utf-8'),
    'z': ContentType('application', 'x-compress', charset: 'utf-8'),
    'tgz': ContentType('application', 'x-compressed', charset: 'utf-8'),
    'cpio': ContentType('application', 'x-cpio', charset: 'utf-8'),
    'csh': ContentType('application', 'x-csh', charset: 'utf-8'),
    'dcr': ContentType('application', 'x-director', charset: 'utf-8'),
    'dir': ContentType('application', 'x-director', charset: 'utf-8'),
    'dxr': ContentType('application', 'x-director', charset: 'utf-8'),
    'dvi': ContentType('application', 'x-dvi', charset: 'utf-8'),
    'gtar': ContentType('application', 'x-gtar', charset: 'utf-8'),
    'gz': ContentType('application', 'x-gzip', charset: 'utf-8'),
    'hdf': ContentType('application', 'x-hdf', charset: 'utf-8'),
    'ins': ContentType('application', 'x-internet-signup', charset: 'utf-8'),
    'isp': ContentType('application', 'x-internet-signup', charset: 'utf-8'),
    'iii': ContentType('application', 'x-iphone', charset: 'utf-8'),
    'js': ContentType('application', 'javascript', charset: 'utf-8'),
    'latex': ContentType('application', 'x-latex', charset: 'utf-8'),
    'mdb': ContentType('application', 'x-msaccess', charset: 'utf-8'),
    'crd': ContentType('application', 'x-mscardfile', charset: 'utf-8'),
    'clp': ContentType('application', 'x-msclip', charset: 'utf-8'),
    'dll': ContentType('application', 'x-msdownload', charset: 'utf-8'),
    'm13': ContentType('application', 'x-msmediaview', charset: 'utf-8'),
    'm14': ContentType('application', 'x-msmediaview', charset: 'utf-8'),
    'mvb': ContentType('application', 'x-msmediaview', charset: 'utf-8'),
    'wmf': ContentType('application', 'x-msmetafile', charset: 'utf-8'),
    'mny': ContentType('application', 'x-msmoney', charset: 'utf-8'),
    'pub': ContentType('application', 'x-mspublisher', charset: 'utf-8'),
    'scd': ContentType('application', 'x-msschedule', charset: 'utf-8'),
    'trm': ContentType('application', 'x-msterminal', charset: 'utf-8'),
    'wri': ContentType('application', 'x-mswrite', charset: 'utf-8'),
    'nc': ContentType('application', 'x-netcdf', charset: 'utf-8'),
    'pma': ContentType('application', 'x-perfmon', charset: 'utf-8'),
    'pmc': ContentType('application', 'x-perfmon', charset: 'utf-8'),
    'pml': ContentType('application', 'x-perfmon', charset: 'utf-8'),
    'pmr': ContentType('application', 'x-perfmon', charset: 'utf-8'),
    'pmw': ContentType('application', 'x-perfmon', charset: 'utf-8'),
    'p12': ContentType('application', 'x-pkcs12', charset: 'utf-8'),
    'pfx': ContentType('application', 'x-pkcs12', charset: 'utf-8'),
    'p7b': ContentType('application', 'x-pkcs7-certificates', charset: 'utf-8'),
    'spc': ContentType('application', 'x-pkcs7-certificates', charset: 'utf-8'),
    'p7r': ContentType('application', 'x-pkcs7-certreqresp', charset: 'utf-8'),
    'p7c': ContentType('application', 'x-pkcs7-mime', charset: 'utf-8'),
    'p7m': ContentType('application', 'x-pkcs7-mime', charset: 'utf-8'),
    'p7s': ContentType('application', 'x-pkcs7-signature', charset: 'utf-8'),
    'sh': ContentType('application', 'x-sh', charset: 'utf-8'),
    'shar': ContentType('application', 'x-shar', charset: 'utf-8'),
    'swf': ContentType('application', 'x-shockwave-flash', charset: 'utf-8'),
    'sit': ContentType('application', 'x-stuffit', charset: 'utf-8'),
    'sv4cpio': ContentType('application', 'x-sv4cpio', charset: 'utf-8'),
    'sv4crc': ContentType('application', 'x-sv4crc', charset: 'utf-8'),
    'tar': ContentType('application', 'x-tar', charset: 'utf-8'),
    'tcl': ContentType('application', 'x-tcl', charset: 'utf-8'),
    'tex': ContentType('application', 'x-tex', charset: 'utf-8'),
    'texi': ContentType('application', 'x-texinfo', charset: 'utf-8'),
    'texinfo': ContentType('application', 'x-texinfo', charset: 'utf-8'),
    'roff': ContentType('application', 'x-troff', charset: 'utf-8'),
    't': ContentType('application', 'x-troff', charset: 'utf-8'),
    'tr': ContentType('application', 'x-troff', charset: 'utf-8'),
    'man': ContentType('application', 'x-troff-man', charset: 'utf-8'),
    'me': ContentType('application', 'x-troff-me', charset: 'utf-8'),
    'ms': ContentType('application', 'x-troff-ms', charset: 'utf-8'),
    'ustar': ContentType('application', 'x-ustar', charset: 'utf-8'),
    'src': ContentType('application', 'x-wais-source', charset: 'utf-8'),
    'cer': ContentType('application', 'x-x509-ca-cert', charset: 'utf-8'),
    'crt': ContentType('application', 'x-x509-ca-cert', charset: 'utf-8'),
    'der': ContentType('application', 'x-x509-ca-cert', charset: 'utf-8'),
    'pko': ContentType('application', 'ynd.ms-pkipko', charset: 'utf-8'),
    'zip': ContentType('application', 'zip', charset: 'utf-8'),
    'au': ContentType('audio', 'basic', charset: 'utf-8'),
    'snd': ContentType('audio', 'basic', charset: 'utf-8'),
    'mid': ContentType('audio', 'mid', charset: 'utf-8'),
    'rmi': ContentType('audio', 'mid', charset: 'utf-8'),
    'mp3': ContentType('audio', 'mpeg', charset: 'utf-8'),
    'aif': ContentType('audio', 'x-aiff', charset: 'utf-8'),
    'aifc': ContentType('audio', 'x-aiff', charset: 'utf-8'),
    'aiff': ContentType('audio', 'x-aiff', charset: 'utf-8'),
    'm3u': ContentType('audio', 'x-mpegurl', charset: 'utf-8'),
    'ra': ContentType('audio', 'x-pn-realaudio', charset: 'utf-8'),
    'ram': ContentType('audio', 'x-pn-realaudio', charset: 'utf-8'),
    'wav': ContentType('audio', 'x-wav', charset: 'utf-8'),
    'bmp': ContentType('image', 'bmp', charset: 'utf-8'),
    'cod': ContentType('image', 'cis-cod', charset: 'utf-8'),
    'gif': ContentType('image', 'gif', charset: 'utf-8'),
    'ief': ContentType('image', 'ief', charset: 'utf-8'),
    'jpe': ContentType('image', 'jpeg', charset: 'utf-8'),
    'jpeg': ContentType('image', 'jpeg', charset: 'utf-8'),
    'jpg': ContentType('image', 'jpeg', charset: 'utf-8'),
    'jfif': ContentType('image', 'pipeg', charset: 'utf-8'),
    'svg': ContentType('image', 'svg+xml', charset: 'utf-8'),
    'tif': ContentType('image', 'tiff', charset: 'utf-8'),
    'tiff': ContentType('image', 'tiff', charset: 'utf-8'),
    'png': ContentType('image', 'png', charset: 'utf-8'),
    'ras': ContentType('image', 'x-cmu-raster', charset: 'utf-8'),
    'cmx': ContentType('image', 'x-cmx', charset: 'utf-8'),
    'ico': ContentType('image', 'x-icon', charset: 'utf-8'),
    'pnm': ContentType('image', 'x-portable-anymap', charset: 'utf-8'),
    'pbm': ContentType('image', 'x-portable-bitmap', charset: 'utf-8'),
    'pgm': ContentType('image', 'x-portable-graymap', charset: 'utf-8'),
    'ppm': ContentType('image', 'x-portable-pixmap', charset: 'utf-8'),
    'rgb': ContentType('image', 'x-rgb', charset: 'utf-8'),
    'xbm': ContentType('image', 'x-xbitmap', charset: 'utf-8'),
    'xpm': ContentType('image', 'x-xpixmap', charset: 'utf-8'),
    'xwd': ContentType('image', 'x-xwindowdump', charset: 'utf-8'),
    'mht': ContentType('message', 'rfc822', charset: 'utf-8'),
    'mhtml': ContentType('message', 'rfc822', charset: 'utf-8'),
    'nws': ContentType('message', 'rfc822', charset: 'utf-8'),
    'css': ContentType('text', 'css', charset: 'utf-8'),
    '323': ContentType('text', 'h323', charset: 'utf-8'),
    'htm': ContentType('text', 'html', charset: 'utf-8'),
    'html': ContentType('text', 'html', charset: 'utf-8'),
    'stm': ContentType('text', 'html', charset: 'utf-8'),
    'uls': ContentType('text', 'iuls', charset: 'utf-8'),
    'bas': ContentType('text', 'plain', charset: 'utf-8'),
    'c': ContentType('text', 'plain', charset: 'utf-8'),
    'h': ContentType('text', 'plain', charset: 'utf-8'),
    'txt': ContentType('text', 'plain', charset: 'utf-8'),
    'rtx': ContentType('text', 'richtext', charset: 'utf-8'),
    'sct': ContentType('text', 'scriptlet', charset: 'utf-8'),
    'tsv': ContentType('text', 'tab-separated-values', charset: 'utf-8'),
    'htt': ContentType('text', 'webviewhtml', charset: 'utf-8'),
    'htc': ContentType('text', 'x-component', charset: 'utf-8'),
    'etx': ContentType('text', 'x-setext', charset: 'utf-8'),
    'vcf': ContentType('text', 'x-vcard', charset: 'utf-8'),
    'mp2': ContentType('video', 'mpeg', charset: 'utf-8'),
    'mpa': ContentType('video', 'mpeg', charset: 'utf-8'),
    'mpe': ContentType('video', 'mpeg', charset: 'utf-8'),
    'mpeg': ContentType('video', 'mpeg', charset: 'utf-8'),
    'mpg': ContentType('video', 'mpeg', charset: 'utf-8'),
    'mpv2': ContentType('video', 'mpeg', charset: 'utf-8'),
    'mp4': ContentType('video', 'mp4', charset: 'utf-8'),
    'mov': ContentType('video', 'quicktime', charset: 'utf-8'),
    'qt': ContentType('video', 'quicktime', charset: 'utf-8'),
    'lsf': ContentType('video', 'x-la-asf', charset: 'utf-8'),
    'lsx': ContentType('video', 'x-la-asf', charset: 'utf-8'),
    'asf': ContentType('video', 'x-ms-asf', charset: 'utf-8'),
    'asr': ContentType('video', 'x-ms-asf', charset: 'utf-8'),
    'asx': ContentType('video', 'x-ms-asf', charset: 'utf-8'),
    'avi': ContentType('video', 'x-msvideo', charset: 'utf-8'),
    'movie': ContentType('video', 'x-sgi-movie', charset: 'utf-8'),
    'flr': ContentType('x-world', 'x-vrml', charset: 'utf-8'),
    'vrml': ContentType('x-world', 'x-vrml', charset: 'utf-8'),
    'wrl': ContentType('x-world', 'x-vrml', charset: 'utf-8'),
    'wrz': ContentType('x-world', 'x-vrml', charset: 'utf-8'),
    'xaf': ContentType('x-world', 'x-vrml', charset: 'utf-8'),
    'xof': ContentType('x-world', 'x-vrml', charset: 'utf-8'),
  };
}

class _CachedContentDeliveryWithLastModified extends StatefulEndpoint {
  _CachedContentDeliveryWithLastModified(this.files, this.directory,
      {required this.watch, this.before, this.additional = const {}});

  final Future<Map<String, CachedFile>> files;

  ///
  final Map<String, Uint8List> additional;

  ///
  final String directory;

  ///
  final bool watch;

  final Future Function()? before;

  @override
  EndpointState<StatefulEndpoint> createState() =>
      _CachedFileServiceWithLastModifiedWithWatchState();
}

class _CachedFileServiceWithLastModifiedWithWatchState
    extends LastModifiedEndpointState<_CachedContentDeliveryWithLastModified> {
  late Map<String, CachedFile> cachedFiles = {};

  bool initialized = false;

  @override
  void initState() {
    component.files.then((value) {
      cachedFiles = value;
      cachedFiles.addAll(component.additional.map((key, value) =>
          MapEntry(key, CachedFile(key, value, DateTime.now()))));
      initialized = true;
    });
    if (component.watch) {
      ContentDelivery._watch(component.directory, component.before)
          .then((value) => value.listen((event) async {
                cachedFiles.clear();
                cachedFiles.addAll(await ContentDelivery._cacheFiles(
                    component.directory, () async {}));
              }));
    }
    super.initState();
  }

  @override
  FutureOr<ResponseWithLastModified> onRequest(
      ValidationRequest<DateTime> request) {
    var file = request.body?.data as String;

    if (!cachedFiles.containsKey(file)) {
      throw NotFoundException();
    }

    return ResponseWithLastModified(cachedFiles[file]!.data,
        request: request,
        contentType:
            ContentDelivery._contentTypes[cachedFiles[file]!.extension] ??
                ContentDelivery._contentTypes['*']!,
        lastModified: cachedFiles[file]!.lastModified);
  }

// @override
// FutureOr<ValidationResponse<DateTime>> lastModified(
//     ValidationRequest<DateTime> request) {
//   var file = request.body?.data as String;
//   if (cachedFiles[file] == null) {
//     throw NotFoundException();
//   }
//   return request.validate(cachedFiles[file]?.lastModified,
//       contentType:
//           DocumentService._contentTypes[cachedFiles[file]!.extension] ??
//               DocumentService._contentTypes["*"]!);
// }
}

class _CachedContentDelivery extends StatefulEndpoint {
  _CachedContentDelivery(this.files, this.directory,
      {required this.watch, this.before, this.additional = const {}});

  final String directory;
  final Future<Map<String, CachedFile>> files;
  final bool watch;
  final Future Function()? before;

  ///
  final Map<String, Uint8List> additional;

  @override
  EndpointState<StatefulEndpoint> createState() => __CachedFileServiceState();
}

class __CachedFileServiceState extends EndpointState<_CachedContentDelivery> {
  late Map<String, CachedFile> cachedFiles;

  bool initialized = false;

  @override
  void initState() {
    component.files.then((value) {
      cachedFiles = value;
      cachedFiles.addAll(component.additional.map((key, value) =>
          MapEntry(key, CachedFile(key, value, DateTime.now()))));
      initialized = true;
    });
    if (component.watch) {
      ContentDelivery._watch(component.directory, component.before)
          .then((value) => value.listen((event) async {
                cachedFiles.clear();
                cachedFiles.addAll(await ContentDelivery._cacheFiles(
                    component.directory, () async {}));
              }));
    }
  }

  @override
  FutureOr<Message> onCall(Request request) {
    var file = request.body?.data as String;

    if (!cachedFiles.containsKey(file)) {
      throw NotFoundException();
    }

    return request.response(Body(cachedFiles[file]!.data), headers: {
      HttpHeaders.contentTypeHeader: ContentDelivery
              ._contentTypes[cachedFiles[file]!.extension]
              ?.toString() ??
          ContentDelivery._contentTypes['*']!.toString(),
    });
  }
}

class _ContentDeliveryWithLastModified extends LastModifiedEndpoint {
  _ContentDeliveryWithLastModified(this.directory);

  final String directory;

  @override
  FutureOr<ResponseWithCacheControl<DateTime>> onRequest(
      ValidationRequest<DateTime> request) async {
    var f = File((request.body?.data as String));
    var exists = await f.exists();
    if (exists) {
      var l = f.lastModifiedSync();
      var val = request.validate(l);
      if (val.valid) {
        return ValidationResponse(
          request: request,
          value: l,
          result: val,
        );
      }

      var dotSplit = f.path.split('.');
      var extension = dotSplit.isEmpty ? '*' : dotSplit.last;

      return ResponseWithLastModified(f.readAsBytesSync(),
          request: request,
          lastModified: l,
          contentType: ContentDelivery._contentTypes[extension] ??
              ContentDelivery._contentTypes['*']);
    }
    throw NotFoundException();
  }
}

class _ContentDelivery extends Endpoint {
  _ContentDelivery(this.directory) : super();

  ///
  final String directory;

  @override
  FutureOr<Message> onCall(Request request) async {
    var f = File((request.body?.data as String));
    var exists = await f.exists();

    if (exists) {
      var dotSplit = f.path.split('.');
      var extension = dotSplit.isEmpty ? '*' : dotSplit.last;

      return request.response(Body(f.readAsBytesSync()), headers: {
        HttpHeaders.contentTypeHeader:
            ContentDelivery._contentTypes[extension]?.toString() ??
                ContentDelivery._contentTypes['*']!.toString(),
      });
    } else {
      throw NotFoundException();
    }
  }
}

///
class CachedFile {
  ///
  CachedFile(this.name, this.data, this.lastModified)
      : extension = name.split('.').last;

  ///
  String name;

  ///
  String extension;

  ///
  Uint8List data;

  ///
  DateTime lastModified;
}

///
class Favicon extends StatefulEndpoint {
  ///
  Favicon(this.assetsPath, {RandomGenerator? etagGenerator})
      : etagGenerator = etagGenerator ?? RandomGenerator('[a#]/l(30)');

  ///
  final String assetsPath;

  ///
  final RandomGenerator etagGenerator;

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
  String get faviconPath => '${component.assetsPath}'
      '/favicon.ico';

  ///
  Future<void> _loadIcon() async {
    var entities = <FileSystemEntity>[Directory(component.assetsPath)];

    while (entities.isNotEmpty) {
      for (var en in List<FileSystemEntity>.from(entities)) {
        if (en is Directory) {
          entities.addAll(en.listSync());
        } else {}
        entities.removeAt(0);
      }
    }

    var file = File(faviconPath);
    data = await file.readAsBytes();
    tag = component.etagGenerator.generateString();
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

    if (base.headers['if-none-match'] != null &&
        (base.headers['if-none-match'] as String) == tag) {
      base.response.statusCode = 304;
      base.response.contentLength = 0;
      await base.response.close();
      return NoResponseRequired(request: request);
    }

    if (data == null) {
      await dataLoader;
    }

    base.response.contentLength = data!.length;
    base.response.headers
      ..add(HttpHeaders.contentTypeHeader, ContentType.binary.mimeType)
      ..add(HttpHeaders.cacheControlHeader, 'must-revalidate')
      ..add(HttpHeaders.etagHeader, tag!);
    base.response.add(data!);
    await base.response.close();
    return NoResponseRequired(request: request);
  }
}

/// Always throw
class Throw extends SimpleEndpoint {
  /// Construct exception
  Throw(Exception exception) : super((_, __) => throw exception);
}
