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

library style_object;

import 'dart:convert';

import 'dart:typed_data';

part 'utils/encoder.dart';

part 'utils/constants.dart';

part 'utils/key_collection.dart';

part 'utils/byte_data_reader.dart';

part 'utils/byte_data_writer.dart';

part 'key/style_key.dart';

part 'key/fixed_length.dart';

part 'key/list.dart';

part 'key/object.dart';

part 'data/style_data.dart';

part 'data/object.dart';

part 'data/fixed_length.dart';

part 'data/list.dart';

part 'data/typed_data.dart';

part 'key/typed_data.dart';

part 'data/generated.dart';

part 'key/generated.dart';

part 'meta/object.dart';

part 'meta/dynamic.dart';

part 'meta/meta.dart';

part 'meta/list.dart';
