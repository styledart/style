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

/// It assigns the service entered as the default service (unless re-wrapped)
/// in all contexts under the context in which it was created.
///
/// Example:
///
/// ````dart
///   ServiceWrapper<Crypto>(
///     service: MyCryptoService(),
///     child: MyChild()
///   )
/// ````
///
class ServiceWrapper<B extends BaseService> extends StatelessComponent {
  /// Annotate with service type
  ServiceWrapper({required this.service, required this.child});

  /// Available Services:
  /// - DataAccess
  /// - Logger
  /// - WebSocketService
  /// - HttpService
  /// - Crypto
  final B service;

  ///
  final Component child;

  @override
  StatelessBinding createBinding() => ServiceWrapperBinding<B>(this);

  @override
  Component build(BuildContext context) => child;
}

///
class ServiceWrapperBinding<B extends BaseService> extends StatelessBinding {
  ///
  ServiceWrapperBinding(ServiceWrapper<B> component) : super(component);

  @override
  ServiceWrapper<B> get component => super.component as ServiceWrapper<B>;

  @override
  void buildBinding() {
    component.service.context = this;
    super.buildBinding();
  }

  @override
  void attachToParent(Binding parent) {
    super.attachToParent(parent);
    _setServiceToThisAndParents<B>(component.service);
  }

  @override
  TreeVisitor<Calling> visitCallingChildren(TreeVisitor<Calling> visitor) => child!.visitCallingChildren(visitor);
}

abstract class BaseService {
  BaseService();

  /// The context in which the service attached
  late final BuildContext context;

  /// Service is initialized
  bool initialized = false;

  /// Init Service
  FutureOr<bool> init();

  FutureOr<void> _init() async {
    initialized = await init();
    _initializeCompleter.complete(initialized);
  }

  late final Completer<bool> _initializeCompleter = Completer<bool>();

  /// Wait service is initialized.
  ///
  /// if service initializing is success returns true.
  Future<bool> ensureInitialize() async => await _initializeCompleter.future;
}
