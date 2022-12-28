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
class ExceptionWrapper<T extends Exception> extends StatelessComponent {
  ///
  factory ExceptionWrapper(
          {required Component child,
          required ExceptionEndpoint<T> exceptionEndpoint,
          Key? key}) =>
      ExceptionWrapper.fromMap(
          child: child, map: {T: exceptionEndpoint}, key: key);

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
  Component build(BuildContext context) => child;

  @override
  StatelessBinding createBinding() => _ExceptionWrapperBinding(this);
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
    var bindings = <Type, ExceptionEndpointCallingBinding>{};
    for (var w in component._map.entries) {
      bindings[w.key] = w.value.createBinding();
    }
    _exceptionHandler ??= ExceptionHandler({});
    exceptionHandler._map.addAll(bindings);
    var p = _parent;
    while (p != null && p._exceptionHandler == null) {
      p._exceptionHandler = _exceptionHandler;
      p = p._parent;
    }
    for (var b in bindings.values) {
      b.attachToParent(this);
      b.buildBinding();
    }
    for (var b in bindings.values) {
      var r = b.visitChildren(TreeVisitor((visitor) {
        if (visitor.currentValue.component
                is PathSegmentCallingComponentMixin ||
            visitor.currentValue is GatewayBinding) {
          visitor.stop();
        }
      }));
      if (r.result != null) {
        throw Exception('[exception] tree must ends with Endpoint'
            '\nAnd must not have a new route\n'
            "Ensure exception/exception's any child not [Route, RouteTo, GateWay]\n"
            'WHERE: $_errorWhere');
      }
    }

    super.buildBinding();
  }

  @override
  ExceptionWrapper get component => super.component as ExceptionWrapper;
}
