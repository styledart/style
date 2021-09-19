part of '../run.dart';

class PathRouter extends SingleChildCallingComponent
    with PathSegmentBindingMixin {
  PathRouter(
      {required PathSegment segment,
      required Component child,
      Endpoint? root,
      Endpoint? unknown})
      : _segment = segment,
        _unknown = unknown ?? UnknownEndpoint(),
        _root = root ?? UnknownEndpoint(),
        super(child);

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

  final Endpoint _unknown, _root;

  @override
  Endpoint get root => _root;

  @override
  Endpoint get unknown => _unknown;
}

class PathRouterCalling extends Calling {
  PathRouterCalling(SingleChildCallingBinding binding)
      : super(binding: binding);

  @override
  FutureOr<void> onCall(StyleRequest request) {
    // TODO: implement onCall
    throw UnimplementedError();
  }
}

abstract class PathSegment {
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

  final String name;

  bool get isUnknown => name == "*unknown";

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

class NamedSegment extends PathSegment {
  const NamedSegment(String name) : super._(name);
}

class ArgumentSegment extends PathSegment {
  const ArgumentSegment(String name) : super._(name);

  @override
  String toString() {
    return "{$name}";
  }
}

abstract class CallingPathSegment {
  factory CallingPathSegment(
      {required PathSegment segment, required String value}) {
    if (segment is NamedSegment) {
      return NamedCallingSegment(segment: segment, name: value);
    } else {
      return ArgumentCallingSegment(
          value: value, segment: segment as ArgumentSegment);
    }
  }

  factory CallingPathSegment.unknown() {
    return CallingPathSegment(
        segment: PathSegment("*unknown"), value: "*unknown");
  }

  const CallingPathSegment._({required this.value, required this.segment});

  final PathSegment segment;
  final String value;

  @override
  String toString() {
    return value;
  }
}

class NamedCallingSegment extends CallingPathSegment {
  const NamedCallingSegment(
      {required NamedSegment segment, required String name})
      : super._(segment: segment, value: name);
}

class ArgumentCallingSegment extends CallingPathSegment {
  const ArgumentCallingSegment(
      {required String value, required ArgumentSegment segment})
      : super._(value: value, segment: segment);

  @override
  String toString() {
    return "{$value}";
  }
}

mixin PathSegmentBindingMixin on CallingComponent {
  PathSegment get segment;

  Endpoint get root;

  Endpoint get unknown;
}

class PathController {
  PathController(this.calledPath) : notProcessedValues = calledPath.split("/") {
    current = notProcessedValues.isEmpty ? "*root" : notProcessedValues.first;
  }

  final String calledPath;
  final List<CallingPathSegment> processed = [];
  late String current;
  final List<String> notProcessedValues;

  CallingPathSegment resolveFor(List<PathSegment> segments) {
    CallingPathSegment? result;

    List<String> _segments = segments.map((e) => e.name).toList();

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
        PathSegment argSeg = segments.firstWhere(
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
