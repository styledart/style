/*
 * Copyright 2021 styledart.dev - Mehmet Yaz
 *
 * Licensed under the GNU AFFERO GENERAL PUBLIC LICENSE, Version 3 (the "License");
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

import 'package:binary_tree/binary_tree.dart';
import 'package:style_query/style_query.dart';
import 'package:style_random/style_random.dart';

import 'exceptions.dart';
import 'index/index_duplication.dart';
import 'index/nested_iterator.dart';

part 'database/collection.dart';

part 'database/database.dart';

part 'index/index.dart';

part 'index/sorted_index.dart';

part 'index/object_index.dart';

part 'storage/storage.dart';

const _idKey = '__id';
