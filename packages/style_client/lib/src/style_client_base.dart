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

import 'dart:async';

import 'modules/http/http_module.dart';
import 'modules/modules.dart';

///
final StyleClient client = StyleClient();

///
class StyleClient {
  ///
  factory StyleClient() => _client;

  StyleClient._();

  static final StyleClient _client = StyleClient._();

  ///
  late final HttpClientModule? _defaultHttp;
  late final WebSocketModule? _defaultWs;

  ///
  bool _wsPreferred = true;

  ///
  FutureOr<void> init(
      {required String serverAddress,
      List<StyleModule>? modules,
      String? defaultHttpModuleKey,
      String? defaultWsModuleKey,
      bool? wsPreferred}) async {
    if (_init) {
      throw ArgumentError("StyleClient already init");
    }

    if (serverAddress.endsWith("/")) {
      serverAddress = serverAddress.substring(0, serverAddress.length - 1);
    }

    this.serverAddress = serverAddress;
    this.modules =
        (modules ?? []).asMap().map((key, value) => MapEntry(value.key, value));
    if (this.modules.isEmpty) {
      throw UnsupportedError("No modules found");
    }

    String? _defaultHttpKey, _defaultWsKey;

    if (defaultHttpModuleKey != null) {
      if (moduleByKey(defaultHttpModuleKey) == null) {
        throw ArgumentError("Default Http Module not found");
      }
      _defaultHttpKey = defaultHttpModuleKey;
    }

    if (defaultWsModuleKey != null) {
      if (moduleByKey(defaultWsModuleKey) == null) {
        throw ArgumentError("Default WS Module not found");
      }
      _defaultWsKey = defaultWsModuleKey;
    }

    if (wsPreferred != null) {
      _wsPreferred = wsPreferred;
      if (_wsPreferred) {
        var ws = module<WebSocketModule>(defaultWsModuleKey);
        if (ws == null) {
          throw ArgumentError("WS Preferred but WS module not found");
        }
      }
    }

    _defaultHttp = module<HttpClientModule>(_defaultHttpKey);
    _defaultWs = module<WebSocketModule>(_defaultWsKey);

    if (_defaultHttp == null && _defaultWs == null) {
      throw ArgumentError("Any conversation module(http or ws) not found");
    }

    var initializers = <Future>[];

    for (var module in this.modules.entries) {
      initializers.add(module.value.init());
    }

    await Future.wait(initializers);

    _init = true;
  }

  ///
  bool _init = false;

  /// server root address
  late String serverAddress;

  ///
  late Map<String, StyleModule> modules;

  /// If module is not exists the function throw error
  /// Search with  exact type
  T? module<T extends StyleModule>([String? key]) {
    if (key != null) return modules[key] as T?;
    return modules.values.whereType<T>().first;
  }

  ///
  StyleModule? moduleByKey(String key) {
    return modules[key];
  }
}


///
abstract class EncryptionModule extends StyleModule {
  ///
  EncryptionModule({required String key}) : super(key: key);
}

///
abstract class WebSocketModule extends StyleModule {
  ///
  WebSocketModule({required String key}) : super(key: key);
}

///
abstract class AnalyticsModule extends StyleModule {
  ///
  AnalyticsModule({required String key}) : super(key: key);
}


