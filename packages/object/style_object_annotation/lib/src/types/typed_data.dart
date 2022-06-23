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

import 'package:style_object_annotation/src/types/type.dart';

enum ListType {
  uint8(9),
  uint16(11),
  uint32(13),
  uint64(19),
  int8(10),
  int16(12),
  int32(14),
  int64(15),
  float32(21),
  float64(22);

  const ListType(this.type);

  final int type;
}

class TypedDataType extends StyleType {
  const TypedDataType(
      {required this.listType,
      this.fixedLength,
      super.key,
      super.name,
      required super.type});

  final int? fixedLength;
  final ListType listType;
}
