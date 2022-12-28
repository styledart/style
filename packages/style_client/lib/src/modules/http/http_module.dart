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

import 'dart:async';

import '../conversation/conversation_mixin.dart';
import '../conversation/request.dart';
import '../conversation/response.dart';

import '../modules.dart';

///
class HttpClientModule extends StyleModule with ConversationMixin {
  ///
  HttpClientModule({required String key}) : super(key: key);

  @override
  void listen(
      FutureOr<StyleClientResponse> Function(StyleServerRequest request)
          onMessage) async {
    //
    // StyleServerRequest? req;
    // var res = await onMessage(req!);
    
  }

  @override
  Future<StyleResponse> request(StyleRequest request) {
    // TODO: implement request
    throw UnimplementedError();
  }
}
