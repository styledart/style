part of '../../style_base.dart';

/// Adds a new single sub-path or endpoint segment to parent path
///
/// ### [child] to create sub-segments.
/// ### [root] to create endpoint for this segment.
/// ### [unknown] to customize unknown route for this segment
/// and sub-segments.
///
///
/// You can use as split route for sub-segments and this segment.
/// For this use case [child] and [root] both must be defined.
///
///
///
///  * [segment] of ['new_segment'] is adding
///  segment to parent like:
///
/// ```
/// parent/path/new_segment/(...?)
/// ```
///
/// Look [PathSegment] for argument segments.
///
///  * [root] Running when this segment is called as an endpoint.
///  [root] is null responded with [unknown]
///  Next [CallingComponent] from [root] calling in example request:
///
/// ```
/// parent/path/new_segment
/// ```
///
///  * [child] Running when this segments known
///  sub-route is called as an endpoint.
///
/// `parent/path/new_segment/known_route`
///
///  * [unknown] Running when this segments unknown
///  sub-route is called as an endpoint.
///  [unknown] is null responded with first parent [unknown]
///
/// `parent/path/new_segment/any_unknown_route`
///
///
/// # -
///
/// ### Example Dart Code:
/// ```dart
///   /// defined from parent path "host/user"
///   return PathRouter(
///     segment: PathSegment("info"),
///     root: MyUserInfoEndpoint()
///   );
/// ```
/// Added route of `host/user/info` .
/// if request path is `host/user/info` calling next [CallingComponent] from [root].
///
/// ### Detailed
///
/// [PathRouter] component helps to
/// * Adding new single child segments to calling tree
/// * Adding unknown endpoint to this segment
/// * Adding root endpoint to this segment a
class PathRouter extends SingleChildCallingComponent
    with PathSegmentBindingMixin {
  /// For argument segments use segment with "{segment}" .
  /// [child], [root] and [unknown]
  PathRouter.withPathSegment(
      {required PathSegment segment,
      Component? child,
      Component? root,
      Component? unknown})
      : _segment = segment,
        _unknown = unknown,
        _root = root,
        super(child);

  /// For argument segments use segment with "{segment}" .
  /// [child], [root] and [unknown] is parent [unknown] in default
  /// for custom [PathSegment] to use constructor [PathRouter.withPathSegment]
  factory PathRouter({required String segment,
    Component? child,
    Component? root,
    Component? unknown}){
    return PathRouter.withPathSegment(segment: PathSegment(segment));
  }


  final PathSegment _segment;

  @override
  PathSegment get segment => _segment;

  @override
  String toString() {
    return "PathRouter(\"${segment.name}\")";
  }

  @override
  Calling createCalling(BuildContext context) =>
      PathRouterCalling(context as SingleChildCallingBinding);

  @override
  SingleChildCallingBinding createBinding() => SingleChildCallingBinding(this);

  final Component? _unknown, _root;

  @override
  Component? get root => _root;

  @override
  Component? get unknown => _unknown;
}


//TODO: PathRouter Calling Binding

/// [PathRouterCalling] call on request this segment.
/// And route to [child] or [unknown] or [root] which is called
/// as endpoint
class PathRouterCalling extends Calling {

  /// if child isn't null, creating bindings
  PathRouterCalling(SingleChildCallingBinding binding)
      : super(binding: binding);

  @override
  FutureOr<void> onCall(Request request) {
    // TODO: implement onCall
    throw UnimplementedError();
  }
}

/// Each path partition (between "/") is [PathSegment].
///
/// [PathSegment] only use for building call tree.
///
///
/// There is two kind of PathSegment.
/// ```
/// host/{user}/info
/// ```
/// * [NamedSegment] is not handle any parameters.
/// "info" is named segment.
///
///
///
/// * [ArgumentSegment] is handle this segment value
/// and next route if possible.
/// "{user}" is argument segment
///
/// Look [CallingPathSegment] for happening values during the call.
@immutable
abstract class PathSegment {


  /// Automatically create [ArgumentSegment] or [NamedSegment].
  ///
  /// For [ArgumentSegment], name must be starts with ":" or wrapped with "{}"
  factory PathSegment(String name) {
    if (name.startsWith(":") || (name.startsWith("{") && name.endsWith("}"))) {
      String _name;
      if (name.startsWith(":")) {
        _name = name.substring(1, name.length);
      } else {
        _name = name.substring(1, name.length - 1);
      }
      return ArgumentSegment(_name);
    } else {
      return NamedSegment(name);
    }
  }

  const PathSegment._(this.name);

  /// Path Segment Name
  final String name;

  /// Path Segment is unknown.
  /// if isUnknown is true, calling
  /// unknown route of binding
  bool get isUnknown => name == "*unknown";


  /// Is root of parent segment
  ///
  /// if client call `host/user`,
  /// path converting to 'host/user/*root'
  /// for only internal operations
  bool get isRoot => name == "*root";

  @override
  bool operator ==(Object other) =>
      other.runtimeType == runtimeType && (other as PathSegment).name == name;

  @override
  String toString() {
    return name;
  }

  @override
  int get hashCode => Object.hash(name, runtimeType);
}


/// ```
/// host/{user}/info
/// ```
/// * [NamedSegment] is not handle any parameters.
/// "info" is named segment.
class NamedSegment extends PathSegment {

  /// Not use with ":" or "{}"
  const NamedSegment(String name) : super._(name);
}

/// ```
/// host/{user}/info
/// ```
/// * [ArgumentSegment] is handle this segment value
/// and next route if possible.
/// "{user}" is argument segment
class ArgumentSegment extends PathSegment {

  /// Not use without ":" or "{}"
  const ArgumentSegment(String name) : super._(name);

  @override
  String toString() {
    return "{$name}";
  }
}

/// Happening [PathSegment] on during the call
///
/// Carries happening values
abstract class CallingPathSegment {

  /// Don't use
  factory CallingPathSegment(
      {required PathSegment segment, required String value}) {
    if (segment is NamedSegment) {
      return NamedCallingSegment(segment: segment, name: value);
    } else {
      return ArgumentCallingSegment(
          value: value, segment: segment as ArgumentSegment);
    }
  }

  /// create unknown path segment
  factory CallingPathSegment.unknown() {
    return CallingPathSegment(
        segment: PathSegment("*unknown"), value: "*unknown");
  }

  const CallingPathSegment._({required this.value, required this.segment});

  /// Takes a segment when the actual and defined segments match.
  final PathSegment segment;

  /// Takes a value when the actual and defined segments match.
  /// Otherwise is segment is unknown or root value is empty.
  ///
  /// in NamedCallingSegment value is segment name
  final String value;

  @override
  String toString() {
    return value;
  }
}

/// Happening [NamedSegment] on during the call
class NamedCallingSegment extends CallingPathSegment {

  ///
  const NamedCallingSegment(
      {required NamedSegment segment, required String name})
      : super._(segment: segment, value: name);
}


/// Happening [ArgumentSegment] on during the call
class ArgumentCallingSegment extends CallingPathSegment {

  ///
  const ArgumentCallingSegment(
      {required String value, required ArgumentSegment segment})
      : super._(value: value, segment: segment);

  @override
  String toString() {
    return "{$value}";
  }
}

/// Each object in the call tree is generated by a [CallingComponent].
/// Some [Calling]s in the tree create a path segment.
mixin PathSegmentBindingMixin on CallingComponent {

  /// This Calling Component segment
  PathSegment get segment;

  /// Using this segment calling as a endpoint
  Component? get root;

  /// Using unknown sub-segments
  Component? get unknown;
}

/// [PathController] is controller for during the call
/// and visiting call tree callings.
///
class PathController {

  ///
  PathController(this.calledPath) : notProcessedValues = calledPath.split("/") {
    current = notProcessedValues.isEmpty ? "*root" : notProcessedValues.first;
  }

  /// Called full path
  final String calledPath;

  /// The processed paths are kept here as the call progresses through the tree.
  final List<CallingPathSegment> processed = [];

  /// First segment to be processed
  late String current;

  /// Next segments to be processed,
  /// include current
  final List<String> notProcessedValues;

  /// Each PathSegmentCalling calls resolveFor for its children.
  /// resolveFor return subsegments that need to be called.
  CallingPathSegment resolveFor(List<PathSegment> segments) {
    CallingPathSegment? result;

    var _segments = segments.map((e) => e.name).toList();

    if (notProcessedValues.isEmpty) {
      result =
          CallingPathSegment(segment: PathSegment("*root"), value: "*root");
    } else {
      current = notProcessedValues.first;
      if (_segments.contains(current)) {
        var seg = segments.firstWhere((element) => element.name == current);
        result =
            NamedCallingSegment(segment: seg as NamedSegment, name: current);
      } else {
        var argSeg = segments.firstWhere(
            (element) => element.runtimeType == ArgumentSegment, orElse: () {
          return PathSegment("*unknown");
        });

        if (argSeg.isUnknown) {
          result = CallingPathSegment(segment: argSeg, value: "*unknown");
        } else {
          result = ArgumentCallingSegment(
              value: current, segment: argSeg as ArgumentSegment);
        }
      }
      processed.add(result);
      notProcessedValues.removeAt(0);
      if (notProcessedValues.isNotEmpty) {
        current = notProcessedValues.first;
      }
    }
    return result;
  }
}
