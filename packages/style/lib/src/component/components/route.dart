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
/// [RouteBase] component helps to
/// * Adding new single child segments to calling tree
/// * Adding unknown endpoint to this segment
/// * Adding root endpoint to this segment a
class RouteBase extends CallingComponent with PathSegmentCallingComponentMixin {
  /// For argument segments use segment with "{segment}" .
  /// [child], [root] and [unknown]
  RouteBase.withPathSegment(
      {required PathSegment segment,
      Component? child,
      Component? root,
      bool? handleUnknownAsRoot})
      : _segment = segment,
        _root = root,
        _child = child,
        handleUnknownAsRoot = handleUnknownAsRoot ?? false,
        assert(child != null || root != null, 'Child or Root must be defined'),
        super();

  /// For argument segments use segment with "{segment}" .
  /// [child], [root] and [unknown] is parent [unknown] in default
  /// for custom [PathSegment] to use constructor [PathRouter.withPathSegment]
  factory RouteBase(String segment,
          {Component? child, Component? root, bool? handleUnknownAsRoot}) =>
      RouteBase.withPathSegment(
          segment: PathSegment(segment),
          child: child,
          root: root,
          handleUnknownAsRoot: handleUnknownAsRoot);

  final PathSegment _segment;

  ///
  final bool handleUnknownAsRoot;

  @override
  PathSegment get segment => _segment;

  @override
  String toString() => 'PathRouter("${segment.name}")';

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
  RouteBinding(RouteBase component) : super(component);

  @override
  void attachToParent(Binding parent) {
    super.attachToParent(parent);
    if (findAncestorBindingOfType<GatewayBinding>() == null) {
      throw UnsupportedError('''
      Incorrect use of parent component
      [Route] working with Gateway.
      But using with: $parent , ${parent.component}
      if you want to only one route use [RouteTo] component
      WHERE: $_errorWhere
      ''');
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
  void buildBinding() {
    _calling = component.createCalling(this);
    rootBinding = component._root?.createBinding();
    childBinding = component._child?.createBinding();

    childBinding?.attachToParent(
      this,
    );
    rootBinding?.attachToParent(
      this,
    );

    childBinding?.buildBinding();
    rootBinding?.buildBinding();

    if (rootBinding != null) {
      var rootGateway =
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
          rootGateway.result == null,
          'Not push gateway or new sub-route from root'
          '\nwhere: $_errorWhere');
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
        throw UnsupportedError('''
          if use child, must put gateway the tree
          Route child using for define sub-segments
          
          WHERE: $_errorWhere
          
          ''');
      }

      _childGateway = childGateway.result as GatewayCalling;
    }

    if ((component.segment.isRoot || component.segment.isUnknown)) {
      if (component.child != null) {
        throw UnsupportedError('''
        root route of [Route] or root route of [Service]
        or unknown routes,
        Must not create any new route 
        
        WHERE: $_errorWhere
          
        ''');
      }
    }
  }

  @override
  TreeVisitor<Calling> callingVisitor(TreeVisitor<Calling> visitor) {
    if (visitor.stopped) return visitor;
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
    if (visitor.stopped) return visitor;
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
  RouteBase get component => super.component as RouteBase;
}

/// [RouteCalling] call on request this segment.
/// And route to [child] or [unknown] or [root] which is called
/// as endpoint
class RouteCalling extends Calling {
  /// if child isn't null, creating bindings
  RouteCalling(RouteBinding binding) : super(binding);

  @override
  RouteBinding get binding => super.binding as RouteBinding;

  @override
  FutureOr<Message> onCall(Request request) {
    var n = request.path
        .resolveFor(binding._childGateway?.childrenBinding.keys.toList() ?? []);
    if (n.segment.isRoot && binding.component.root == null) {
      throw NotFoundException(
          '/${request.path.processed.last.segment.name}/$n');
    }
    if (n.segment.isUnknown) {
      if (binding.component.handleUnknownAsRoot) {
        return binding.rootBinding!.findCalling.calling(request);
      }
      throw NotFoundException(
          '${request.path.next} : /${request.path.processed.last.segment.name}');
    }
    if (n.segment.isRoot) {
      return binding.rootBinding!.findCalling.calling(request);
    }
    return binding.childBinding!.findCalling.calling(request);

    //
    //
    // binding.rootBinding.findCalling.calling(request);
    //
    // if (n.segment.isRoot) {
    //   return (binding.rootBinding ?? binding.exceptionHandler.unknown)
    //       .findCalling
    //       .calling(request);
    // } else if (n.segment.isUnknown) {
    //   return (binding.component.handleUnknownAsRoot
    //           ? binding.rootBinding!
    //           : binding.exceptionHandler.unknown)
    //       .findCalling
    //       .calling(request);
    // } else {
    //   return (binding._childGateway!.binding).findCalling.calling(request);
    // }
    // } on Exception catch (e) {
    //   return binding.exceptionHandler[e.runtimeType].findCalling
    //       .calling(request);
    // }
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
    name = name.trim();
    if (name.startsWith(':') || (name.startsWith('{') && name.endsWith('}'))) {
      String segment;
      if (name.startsWith(':')) {
        segment = name.substring(1, name.length);
      } else {
        segment = name.substring(1, name.length - 1);
      }
      return ArgumentSegment(segment);
    } else {
      return NamedSegment(name);
    }
  }

  ///
  bool get isArgument => this is ArgumentSegment;

  const PathSegment._(this.name);

  /// Path Segment Name
  final String name;

  /// Path Segment is unknown.
  /// if isUnknown is true, calling
  /// unknown route of binding
  bool get isUnknown => name == '*unknown';

  /// Is root of parent segment
  ///
  /// if client call `host/user`,
  /// path converting to 'host/user/*root'
  /// for only internal operations
  bool get isRoot => name == '*root';

  @override
  bool operator ==(Object other) => other is PathSegment && other.name == name;

  @override
  String toString() => name;

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
  String toString() => name;
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
  String toString() => '{$name}';
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
  factory CallingPathSegment.unknown() =>
      CallingPathSegment(segment: PathSegment('*unknown'), value: '*unknown');

  const CallingPathSegment._({required this.value, required this.segment});

  /// Takes a segment when the actual and defined segments match.
  final PathSegment segment;

  /// Takes a value when the actual and defined segments match.
  /// Otherwise is segment is unknown or root value is empty.
  ///
  /// in NamedCallingSegment value is segment name
  final String value;

  @override
  String toString() => value;
}

/// Happening [NamedSegment] on during the call
class NamedCallingSegment extends CallingPathSegment {
  ///
  NamedCallingSegment({required NamedSegment segment})
      : super._(segment: segment, value: segment.name);

  @override
  String toString() => 'CallingPath($value) match $segment';
}

/// Happening [ArgumentSegment] on during the call
class ArgumentCallingSegment extends CallingPathSegment {
  ///
  const ArgumentCallingSegment(
      {required String value, required ArgumentSegment segment})
      : super._(value: value, segment: segment);

  @override
  String toString() => 'CallingPath({$value}) match $segment';
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
  PathController(
    this.calledPath,
    this.queryParameters,
  ) : notProcessedValues = List.from(Uri.parse(calledPath).pathSegments);

  ///
  PathController.fromFullPath(this.calledPath)
      : notProcessedValues = List.from(Uri.parse(calledPath).pathSegments) {
    next = notProcessedValues.isEmpty ? '*root' : notProcessedValues.first;
    queryParameters = Uri.parse(calledPath).queryParameters;
  }

  ///
  PathController.fromHttpRequest(HttpRequest request)
      : notProcessedValues = List.from(request.uri.pathSegments),
        calledPath = request.uri.path,
        queryParameters = request.uri.queryParameters {
    next = notProcessedValues.isEmpty ? '*root' : notProcessedValues.first;
  }

  ///
  late final Map<String, String> queryParameters;

  /// Called full path
  final String calledPath;

  /// Store path arguments like:
  /// <br> <br>
  /// path : "user/{user_id}/path"<br>
  /// call : "user/user1/path"
  /// <br> <br>
  /// arguments stored key value pair:
  ///
  /// ```json
  /// {
  ///   "user_id" : "user1"
  /// }
  /// ```
  ///
  final Map<String, String> arguments = {};

  /// The processed paths are kept here as the call progresses through the tree.
  final List<CallingPathSegment> processed = [];

  /// First segment to be processed
  String next = '';

  /// Next segments to be processed,
  /// include current
  final List<String> notProcessedValues;

  /// Each PathSegmentCalling calls resolveFor for its children.
  /// resolveFor return subsegments that need to be called.
  CallingPathSegment resolveFor(Iterable<PathSegment> segments) {
    CallingPathSegment? result;
    if (notProcessedValues.isEmpty) {
      result =
          CallingPathSegment(segment: PathSegment('*root'), value: '*root');
    } else {
      next = notProcessedValues.first;
      if (segments.contains(PathSegment(next))) {
        var seg = segments.firstWhere((element) => element.name == next);
        result = NamedCallingSegment(segment: seg as NamedSegment);
      } else {
        var argSeg = segments.firstWhere(
            (element) => element.runtimeType == ArgumentSegment,
            orElse: () => PathSegment('*unknown'));

        if (argSeg.isUnknown) {
          result = NamedCallingSegment(segment: NamedSegment('*unknown'));
        } else {
          result = ArgumentCallingSegment(
              value: next, segment: argSeg as ArgumentSegment);

          arguments[argSeg.name] = next;
          next = '{${argSeg.name}}';
        }
      }
      processed.add(result);
      notProcessedValues.removeAt(0);
    }
    return result;
  }

  ///
  Map<String, dynamic> toMap() => {
        'path': calledPath,
        'query_parameters': queryParameters,
        'arguments': arguments
      };
}

///
class SubRoute extends StatelessComponent {
  ///
  SubRoute(this.segment, {this.child, this.handleUnknownAsRoot, this.root});

  ///
  final String segment;

  ///
  final Component? root;

  ///
  final Component? child;

  ///
  final bool? handleUnknownAsRoot;

  @override
  Component build(BuildContext context) => Gateway(children: [
        RouteBase(segment,
            root: root, handleUnknownAsRoot: handleUnknownAsRoot, child: child)
      ]);
}

///
class Route extends StatelessComponent {
  ///
  Route(
    this.route, {
    this.handleUnknownAsRoot = false,
    this.child,
    this.root,
  });

  ///
  final String route;

  ///
  final Component? root;

  ///
  final Component? child;

  ///
  final bool handleUnknownAsRoot;

  Binding _findAncestorGatewayOrRoute(BuildContext context) {
    var ancestor = context._parent;
    while (ancestor != null &&
        (ancestor is! GatewayBinding && ancestor is! RouteBinding)) {
      ancestor = ancestor._parent;
    }
    if (ancestor == null) {
      throw Exception('Put Cron Job to route or routeTo or gateway');
    }
    return ancestor;
  }

  @override
  Component build(BuildContext context) {
    var anc = _findAncestorGatewayOrRoute(context);

    if (anc is GatewayBinding) {
      return RouteBase(route,
          root: root, child: child, handleUnknownAsRoot: handleUnknownAsRoot);
    } else {
      return SubRoute(route,
          root: root, child: child, handleUnknownAsRoot: handleUnknownAsRoot);
    }
  }
}
