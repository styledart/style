/*
 * Copyright 2021 styledart.dev - Mehmet Yaz
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
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
class Gateway extends MultiChildCallingComponent {
  ///
  Gateway({required List<Component> children}) : super(children);

  @override
  GatewayBinding createBinding() => GatewayBinding(this);

  @override
  Calling createCalling(BuildContext context) =>
      GatewayCalling(binding: context as CallingBinding);
}

///
class GatewayBinding extends MultiChildCallingBinding {
  ///
  GatewayBinding(MultiChildCallingComponent component) : super(component);

  @override
  GatewayCalling get calling => super.calling as GatewayCalling;

  @override
  void attachToParent(Binding parent) {
    super.attachToParent(parent);

    var route = findAncestorBindingOfType<RouteBinding>();
    var service = findAncestorBindingOfType<ServerBinding>();

    if (route == null && service == null) {
      throw UnsupportedError('Each Gateway must ancestor of Service or Route'
          '\nwhere:$_errorWhere');
    }
  }

  @override
  void buildBinding() {
    super.buildBinding();
    var callings = <PathSegment, Binding>{};
    PathSegment? arg;
    for (var child in children) {
      var childCalling = child.visitCallingChildren(TreeVisitor((visitor) {
        if (visitor.currentValue is GatewayCalling) {
          visitor.stop();
          return;
        }
        if (visitor.currentValue is RouteCalling) {
          visitor.stop();
        }
      }));
      if (childCalling.result == null) {
        throw UnsupportedError('Each Gateway child (or Service child) must have'
            '[Route] in the tree.'
            '\nwhere: child ${child.component} in $_errorWhere');
      }
      if (childCalling.result is GatewayCalling) {
        var segments = ((childCalling.result! as GatewayCalling).binding
                as GatewayBinding)
            .calling
            .childrenBinding;

        for (var seg in segments.entries) {
          if (seg.key.isArgument) {
            if (arg != null) {
              throw Exception('Gateways allow only once argument segment.'
                  '\nbut found $arg and'
                  ' $seg\nWHERE: $_errorWhere');
            } else {
              arg = seg.key;
            }
          }
          callings[seg.key] = child;
        }
      } else {
        var seg =
            (childCalling.result! as RouteCalling).binding.component.segment;

        if (seg.isArgument) {
          if (arg != null) {
            throw Exception('Gateways allow only once argument segment.'
                ' \nbut found $arg and'
                ' $seg\nWHERE: $_errorWhere');
          } else {
            arg = seg;
          }
        }
        callings[seg] = child;
      }
    }
    //
    // print(
    //     "${_callings.map((key, value) => MapEntry(key, value.))}");
    calling.childrenBinding = callings;
  }
}

///
class GatewayCalling extends Calling {
  ///
  GatewayCalling({required CallingBinding binding}) : super(binding);

  @override
  MultiChildCallingBinding get binding =>
      super.binding as MultiChildCallingBinding;

  ///
  late final Map<PathSegment, Binding> childrenBinding;

  @override
  FutureOr<Message> onCall(Request request) {
    if (childrenBinding[PathSegment(request.nextPathSegment)] != null) {
      return childrenBinding[PathSegment(request.nextPathSegment)]!
          .findCalling
          .calling(request);
    } else {
      throw NotFoundException(request.nextPathSegment);
    }
  }
}
