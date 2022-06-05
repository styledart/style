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


import 'package:meta/meta.dart';

import '../../style_client.dart';
import 'access/access_module.dart';
import 'auth/auth_module.dart';
import 'http/http_module.dart';

///
abstract class StyleModule {
  ///
  StyleModule(
      {required this.key,
        String? customAuthModuleKey,
        String? customQueryModuleKey,
        String? customEncryptionModuleKey,
        String? customWebSocketModuleKey,
        String? customAnalyticsModuleKey,
        String? customHttpClientKey});

  ///
  String key;

  String? _authModuleKey,
      _accessModuleKey,
      _encryptionModuleKey,
      _webSocketModuleKey,
      _analyticsModuleKey,
      _httpClientKey;

  ///
  late final AuthModule authModule;

  ///
  late final AccessModule accessModule;

  ///
  late final EncryptionModule encryption;

  ///
  late final WebSocketModule webSocket;

  ///
  late final AnalyticsModule analytics;

  ///
  late final HttpClientModule httpClient;

  void _setModule<T extends StyleModule>(String? moduleKey) {
    StyleModule? module;

    if (moduleKey == null) {
      module = client.module<T>();
    } else {
      module = client.moduleByKey(moduleKey) as T?;
    }

    if (module == null) return;

    if (module is AuthModule) {
      authModule = module;
    } else if (module is AccessModule) {
      accessModule = module;
    } else if (module is EncryptionModule) {
      encryption = module;
    } else if (module is WebSocketModule) {
      webSocket = module;
    } else if (module is AnalyticsModule) {
      analytics = module;
    } else if (module is HttpClientModule) {
      httpClient = module;
    }
    return;
  }

  ///
  @mustCallSuper
  Future<void> init() async {
    /// Auth
    _setModule<AuthModule>(_authModuleKey);

    /// Query
    _setModule<AccessModule>(_accessModuleKey);

    /// Encryption
    _setModule<EncryptionModule>(_encryptionModuleKey);

    /// WebSocket
    _setModule<WebSocketModule>(_webSocketModuleKey);

    /// Analytics
    _setModule<AnalyticsModule>(_analyticsModuleKey);

    /// HttpClient
    _setModule<HttpClientModule>(_httpClientKey);
  }
}