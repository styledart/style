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
abstract class Crypto extends BaseService {
  ///
  static Crypto of(BuildContext context) => context.crypto;

  ///
  FutureOr<String> passwordHash(String clearText);

  ///
  FutureOr<String> encrypt(
      String plain, Uint8List clientNonce, Uint8List serverNonce);

  ///
  FutureOr<String> decrypt(
      String cipher, Uint8List clientNonce, Uint8List serverNonce);

  ///
  FutureOr<List<int>> calculateSha256Mac(List<int> plain);

  ///
  FutureOr<List<int>> calculateSha1Mac(List<int> plain);
}
