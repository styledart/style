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
class ExceptionWrapper<T extends Exception> extends StatelessComponent {
  ///
  factory ExceptionWrapper(
      {required Component child,
      required ExceptionEndpoint<T> exceptionEndpoint,
      Key? key}) {
    return ExceptionWrapper.fromMap(child: child, map: {T: exceptionEndpoint});
  }

  ///
  ExceptionWrapper.fromMap(
      {required this.child,
      required Map<Type, ExceptionEndpoint> map,
      Key? key})
      : _map = map,
        super(key: key);

  ///
  final Component child;

  final Map<Type, ExceptionEndpoint> _map;

  @override
  Component build(BuildContext context) {
    return child;
  }

  @override
  StatelessBinding createBinding() {
    return _ExceptionWrapperBinding(this);
  }
}

class _ExceptionWrapperBinding extends StatelessBinding {
  _ExceptionWrapperBinding(ExceptionWrapper component) : super(component);

  @override
  void buildBinding() {
    if (_exceptionHandler == null) {
      component._map.addAll({
        InternalServerError: DefaultExceptionEndpoint<InternalServerError>()
      });
    }
    var _bindings = <Type, ExceptionEndpointCallingBinding>{};
    for (var w in component._map.entries) {
      _bindings[w.key] = w.value.createBinding();
    }
    _exceptionHandler ??= ExceptionHandler({});
    exceptionHandler._map.addAll(_bindings);
    var p = _parent;
    while (p != null && p._exceptionHandler == null) {
      p._exceptionHandler = _exceptionHandler;
      p = p._parent;
    }
    for (var _b in _bindings.values) {
      _b.attachToParent(this);
      _b.buildBinding();
    }
    for (var _b in _bindings.values) {
      var r = _b.visitChildren(TreeVisitor((visitor) {
        if (visitor.currentValue.component
                is PathSegmentCallingComponentMixin ||
            visitor.currentValue is GatewayBinding) {
          visitor.stop();
        }
      }));
      if (r.result != null) {
        throw Exception("[exception] tree must ends with Endpoint"
            "\nAnd must not have a new route\n"
            "Ensure exception/exception's any child not [Route, RouteTo, GateWay]\n"
            "WHERE: $_errorWhere");
      }
    }

    super.buildBinding();
  }

  @override
  ExceptionWrapper get component => super.component as ExceptionWrapper;
}
