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
/// [Route] component helps to
/// * Adding new single child segments to calling tree
/// * Adding unknown endpoint to this segment
/// * Adding root endpoint to this segment a
class Route extends CallingComponent with PathSegmentCallingComponentMixin {
  /// For argument segments use segment with "{segment}" .
  /// [child], [root] and [unknown]
  Route.withPathSegment(
      {required PathSegment segment,
      Component? child,
      Component? root,
      bool? handleUnknownAsRoot})
      : _segment = segment,
        _root = root,
        _child = child,
        handleUnknownAsRoot = handleUnknownAsRoot ?? false,
        assert(child != null || root != null, "Child or Root must be defined"),
        super();

  /// For argument segments use segment with "{segment}" .
  /// [child], [root] and [unknown] is parent [unknown] in default
  /// for custom [PathSegment] to use constructor [PathRouter.withPathSegment]
  factory Route(String segment,
      {Component? child, Component? root, bool? handleUnknownAsRoot}) {
    return Route.withPathSegment(
        segment: PathSegment(segment),
        child: child,
        root: root,
        handleUnknownAsRoot: handleUnknownAsRoot);
  }

  final PathSegment _segment;

  ///
  final bool handleUnknownAsRoot;

  @override
  PathSegment get segment => _segment;

  @override
  String toString() {
    return "PathRouter(\"${segment.name}\")";
  }

  @override
  Calling createCalling(BuildContext context) =>
      RouteCalling(context as RouteBinding);

  @override
  RouteBinding createBinding() => RouteBinding(this);

  final Component? _root, _child;

  @override
  Component? get root => _root;

  @override
  Component? get child => _child;
}

///
class RouteBinding extends CallingBinding {
  ///
  RouteBinding(Route component) : super(component);

  @override
  void attachToParent(Binding parent) {
    super.attachToParent(parent);
    if (findAncestorBindingOfType<GatewayBinding>() == null) {
      throw UnsupportedError("""
      Incorrect use of parent component
      [Route] working with Gateway.
      But using with: $parent , ${parent.component}
      if you want to only one route use [RouteTo] component
      WHERE: $_errorWhere
      """);
    }
  }

  ///
  late Binding? childBinding, rootBinding;

  /// Bu segment altındaki available paths
  /// Bu segment user ise
  ///
  /// host/a/user
  /// rootCalling
  /// root u çağırır
  ///
  /// root altında path segment varsa hata verir
  ///
  /// childdaki gateway aranır. Gateway in mümkün olanları buraya eklenir.
  ///
  ///
  GatewayCalling? _childGateway;

  @override
  void _build() {
    _calling = component.createCalling(this);
    rootBinding = component._root?.createBinding();
    childBinding = component._child?.createBinding();

    childBinding?.attachToParent(
      this,
    );
    rootBinding?.attachToParent(
      this,
    );

    childBinding?._build();
    rootBinding?._build();

    if (rootBinding != null) {
      var _rootGateway =
          rootBinding!.visitCallingChildren(TreeVisitor<Calling>((visitor) {
        if (visitor.currentValue is GatewayCalling) {
          visitor.stop();
          return;
        }
        if (visitor.currentValue.binding.component
            is PathSegmentCallingComponentMixin) {
          visitor.stop();
          return;
        }
      }));

      assert(
          _rootGateway.result == null,
          "Not push gateway or new sub-route from root"
          "\nwhere: $_errorWhere");
    }

    if (childBinding != null) {
      var childGateway =
          childBinding!.visitCallingChildren(TreeVisitor<Calling>((visitor) {
        if (visitor.currentValue is GatewayCalling) {
          visitor.stop();
          return;
        }
      }));
      if (childGateway.result == null) {
        throw UnsupportedError("""
          if use child, must put gateway the tree
          Route child using for define sub-segments
          
          WHERE: $_errorWhere
          
          """);
      }

      _childGateway = childGateway.result as GatewayCalling;
    }

    if ((component.segment.isRoot || component.segment.isUnknown)) {
      if (component.child != null) {
        throw UnsupportedError("""
        root route of [Route] or root route of [Service]
        or unknown routes,
        Must not create any new route 
        
        WHERE: $_errorWhere
          
        """);
      }
    }
  }

  @override
  TreeVisitor<Calling> callingVisitor(TreeVisitor<Calling> visitor) {
    if (visitor._stopped) return visitor;
    visitor(calling);
    if (component.root != null) {
      rootBinding!.visitCallingChildren(visitor);
    }
    if (component.child != null) {
      childBinding!.visitCallingChildren(visitor);
    }
    // if (component.unknown != null) {
    //   unknownBinding!.visitCallingChildren(visitor);
    // }
    return visitor;
  }

  @override
  TreeVisitor<Binding> visitChildren(TreeVisitor<Binding> visitor) {
    if (visitor._stopped) return visitor;
    visitor(this);

    if (rootBinding != null) {
      rootBinding?.visitChildren(visitor);
    }

    if (childBinding != null) {
      childBinding?.visitChildren(visitor);
    }

    return visitor;
  }

  @override
  Route get component => super.component as Route;
}

/// [RouteCalling] call on request this segment.
/// And route to [child] or [unknown] or [root] which is called
/// as endpoint
class RouteCalling extends Calling {
  /// if child isn't null, creating bindings
  RouteCalling(RouteBinding binding) : super(binding);

  RouteBinding get binding => super.binding as RouteBinding;

  @override
  FutureOr<Message> onCall(Request request) {
    try {
      var n = request.path
          .resolveFor(binding._childGateway?.components.keys.toList() ?? []);

      if (n.segment.isRoot) {
        return (binding.rootBinding ?? binding.exceptionHandler.unknown)
            .findCalling
            .calling(request);
      } else if (n.segment.isUnknown) {
        return (binding.component.handleUnknownAsRoot
                ? binding.rootBinding!
                : binding.exceptionHandler.unknown)
            .findCalling
            .calling(request);
      } else {
        return (binding._childGateway!.binding).findCalling.calling(request);
      }
    } on Exception catch (e) {
      return binding.exceptionHandler[e.runtimeType].findCalling
          .calling(request);
    }
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

  @override
  String toString() {
    return "NamedSegment($name)";
  }
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
    return "ArgSegment($name)";
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
      return NamedCallingSegment(segment: segment);
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
  NamedCallingSegment({required NamedSegment segment})
      : super._(segment: segment, value: segment.name);

  @override
  String toString() {
    return "CallingPath($value) match $segment";
  }
}

/// Happening [ArgumentSegment] on during the call
class ArgumentCallingSegment extends CallingPathSegment {
  ///
  const ArgumentCallingSegment(
      {required String value, required ArgumentSegment segment})
      : super._(value: value, segment: segment);

  @override
  String toString() {
    return "CallingPath({$value}) match $segment";
  }
}

/// Each object in the call tree is generated by a [CallingComponent].
/// Some [Calling]s in the tree create a path segment.
mixin PathSegmentCallingComponentMixin on CallingComponent {
  /// This Calling Component segment
  PathSegment get segment;

  /// Using this segment calling as a endpoint
  Component? get root;

  /// Using known child
  Component? get child;
}

/// [PathController] is controller for during the call
/// and visiting call tree callings.
///
class PathController {
  ///
  PathController(this.calledPath)
      : notProcessedValues = calledPath
            .split("/")
            .where((element) => element.isNotEmpty)
            .toList() {
    current = notProcessedValues.isEmpty ? "*root" : notProcessedValues.first;
  }

  /// Called full path
  final String calledPath;

  /// Store path arguments like:
  ///
  /// path : "user/{user_id}/path"
  /// call : "user/user1/path"
  ///
  /// arguments stored key value pair:
  ///
  /// ```
  /// {
  ///   "user_id" : "user1"
  ///   // others
  /// }
  /// ```
  ///
  final Map<String, String> arguments = {};

  /// The processed paths are kept here as the call progresses through the tree.
  final List<CallingPathSegment> processed = [];

  /// First segment to be processed
  late String current;

  /// Next segments to be processed,
  /// include current
  final List<String> notProcessedValues;

  /// Each PathSegmentCalling calls resolveFor for its children.
  /// resolveFor return subsegments that need to be called.
  CallingPathSegment resolveFor(Iterable<PathSegment> segments) {
    CallingPathSegment? result;
    if (notProcessedValues.isEmpty) {
      result =
          CallingPathSegment(segment: PathSegment("*root"), value: "*root");
    } else {
      current = notProcessedValues.first;
      if (segments.contains(PathSegment(current))) {
        var seg = segments.firstWhere((element) => element.name == current);
        result = NamedCallingSegment(segment: seg as NamedSegment);
      } else {
        var argSeg = segments.firstWhere(
            (element) => element.runtimeType == ArgumentSegment, orElse: () {
          return PathSegment("*unknown");
        });

        if (argSeg.isUnknown) {
          result = NamedCallingSegment(segment: NamedSegment("*unknown"));
        } else {
          result = ArgumentCallingSegment(
              value: current, segment: argSeg as ArgumentSegment);

          arguments[argSeg.name] = current;
          current = "{${argSeg.name}}";
        }
      }
      processed.add(result);
      notProcessedValues.removeAt(0);
    }
    return result;
  }
}

///
class RouteTo extends StatelessComponent {
  ///
  RouteTo(this.segment, {this.child, this.handleUnknownAsRoot, this.root});

  ///
  final String segment;

  ///
  final Component? root;

  ///
  final Component? child;

  ///
  final bool? handleUnknownAsRoot;

  @override
  Component build(BuildContext context) {
    return Gateway(children: [
      Route(segment,
          root: root, handleUnknownAsRoot: handleUnknownAsRoot, child: child)
    ]);
  }
}
