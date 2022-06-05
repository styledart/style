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

import 'dart:typed_data';

void main() {
  var outgoingByteData = ByteData(9);

  outgoingByteData.buffer
      .asUint8List(1, 8)
      .setAll(0, Uint32List.fromList([10, 20]).buffer.asUint8List());

  print(outgoingByteData.buffer.asUint8List()); // [10, 0, 0, 0, 20, 0, 0, 0]
  var ingoingByteData =
      Uint8List.fromList([0, 10, 0, 0, 0, 20, 0, 0, 0]).buffer.asByteData();

  var uint32List =
      ingoingByteData.buffer.asUint8List().sublist(1, 9).buffer.asInt32List(0);

  print(uint32List.toList());
}
