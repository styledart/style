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
import 'dart:convert';
import 'dart:typed_data';

import '../style_query.dart';

/// Client creates a new access or query.
///
/// Clients can converts to desired language
///
/// Server can create a new access or query from a client message.
///
/// Server can convert to desired language
///
class CommonLanguage extends AccessLanguage {}

///
class CommonLanguageDelegate extends AccessLanguageDelegate<CommonLanguage> {
  ///
  const CommonLanguageDelegate() : super('common');

  @override
  CommonAccess fromCommonLanguage(CommonAccess access) {
    return access;
  }

  @override
  CommonAccess toCommonLanguage(covariant CommonAccess access) {
    return access;
  }

  @override
  CommonAccess accessFromJson(JsonMap jsonMap) {
    return CommonAccess.fromJson(jsonMap);
  }

  @override
  CommonQuery queryFromJson(JsonMap jsonMap) {
    return CommonQuery.fromJson(jsonMap);
  }

  @override
  CommonCreateData createDataFromJson(JsonMap jsonMap) {
    return CommonCreateData(jsonMap);
  }

  @override
  CommonUpdate updateDataFromJson(JsonMap jsonMap) {
    return CommonUpdate(jsonMap);
  }
}

///
class CommonQuery extends Query<CommonLanguage> {
  ///
  CommonQuery(
      {this.identifier,
      FilterExpression? filter,
      Map<String, Sorting>? sort,
      this.offset,
      this.limit,
      this.fields})
      : sortExpression = CommonSort(sort ?? <String, Sorting>{});

  ///
  factory CommonQuery.fromJson(JsonMap jsonMap) {
    return CommonQuery(
        identifier: jsonMap['identifier'] as String?,
        sort: jsonMap['sort'] == null
            ? null
            : (jsonMap['sort'] as JsonMap).map(
                (key, value) => MapEntry(key, Sorting.values[value as int])),
        offset: jsonMap['offset'] as int?,
        limit: jsonMap['limit'] as int?);
  }

  ///
  @override
  int? limit, offset;

  @override
  String? identifier;

  @override
  Fields? fields;

  @override
  FilterExpression? filter;

  @override
  SortExpression<CommonLanguage>? sortExpression;

  @override
  Uint8List toBinary() {
    // TODO: implement toBinary
    throw UnimplementedError();
  }

  @override
  JsonMap toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}

///
class CommonSort extends SortExpression<CommonLanguage> {
  ///
  CommonSort(this.sorts) : super();

  @override
  Map<String, Sorting> sorts;
}

///
class CommonUpdate extends UpdateData<CommonLanguage> {
  ///
  CommonUpdate(this.map);

  ///
  JsonMap map;

  @override
  JsonMap toJson() {
    return map;
  }

  @override
  Uint8List toBinary() {
    return utf8.encode(jsonEncode(map)) as Uint8List;
  }

  @override
  Map<String, List<UpdateDifference>> differences() {
    throw UnimplementedError();
  }
}

///
class CommonCreateData extends CreateData<CommonLanguage> {
  ///
  CommonCreateData(this._data);

  ///
  static String idField = 'id';

  final JsonMap _data;

  @override
  JsonMap toJson() => _data;

  @override
  String get id => '${_data[idField]}';

  @override
  Uint8List toBinary() => _data.toBinary();

  @override
  JsonMap get data => _data;
}

///
class CommonAccess extends Access<CommonLanguage> {
  ///
  CommonAccess(
      {required super.type,
      required super.collection,
      CommonQuery? super.query,
      OperationSettings? settings,
      super.pipeline,
      super.createData,
      super.updateData});

  ///
  factory CommonAccess.fromBinary(Uint8List binary) {
    return CommonAccess.fromJson(binary.toJson());
  }

  ///
  factory CommonAccess.fromJson(JsonMap jsonMap) {
    return CommonAccess(
        type: AccessType.values[jsonMap['type'] as int],
        collection: jsonMap['collection'] as String,
        query: jsonMap['query'] != null
            ? CommonQuery.fromJson(jsonMap['query'] as JsonMap)
            : null,
        settings: jsonMap['settings'] == null
            ? null
            : OperationSettings(jsonMap['settings'] as JsonMap),
        createData: jsonMap['createData'] == null
            ? null
            : CommonCreateData(jsonMap['createData'] as JsonMap),
        updateData: CommonUpdate(jsonMap['updateData'] as JsonMap));
  }

  @override
  CommonQuery? get query => super.query as CommonQuery?;

  @override
  JsonMap toJson() {
    return {
      'type': type.index,
      'collection': collection,
      if (query != null) 'query': query?.toJson(),
      if (settings != null) 'settings': settings?.settings,
      if (pipeline != null) 'pipeline': pipeline?.toJson(),
      if (createData != null) 'createData': createData?.toJson(),
      if (updateData != null) 'updateData': updateData?.toJson()
    };
  }
}

///
class CommonFields extends Fields {
  ///
  CommonFields({this.includeKeys, this.excludeKeys});

  @override
  final List<String>? excludeKeys;

  @override
  final List<String>? includeKeys;

  @override
  JsonMap toJson() => {'include': includeKeys, 'exclude': excludeKeys};
}
