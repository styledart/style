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

import 'package:style_object/style_object.dart';

void main() async {
  var codec = StyleObjectCodec();

  var encoder = codec.encoder;
  var decoder = codec.decoder;
  var d = StyleObjectWithKeys({
    10: ListData([
      {2: StringData("Ali")},
      {2: StringData("Veli")},
      {2: StringData("Can")},
    ]),
    4: StringData('String 4'),
    5: Uint16Data(6),
    6: StyleObjectWithKeys({
      100: IntData(1500),
      200: IntData(1800),
    })
  });

  var bytes = encoder.convert(d);

  print(bytes.buffer.asUint8List());

  var res = decoder.convert(bytes);
  print(res);
}
