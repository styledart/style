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
part of '../../style_base.dart';

///
class DbCollection {
  ///
  DbCollection(
    this.collectionName, {
    JsonSchema? createSchema,
    JsonSchema? updateSchema,
    this.triggers,
    PermissionHandler? permissionHandler,
    this.identifier,
    JsonSchema? resourceSchemaOnUpdate,
  })  : permissionHandler = _getHandler(
            permissionHandler: permissionHandler,
            createSchema: createSchema,
            resourceSchemaOnUpdate: resourceSchemaOnUpdate,
            updateSchema: updateSchema),
        hasSchema = resourceSchemaOnUpdate != null ||
            createSchema != null ||
            updateSchema != null;

  static PermissionHandler? _getHandler({
    required JsonSchema? createSchema,
    required JsonSchema? updateSchema,
    required PermissionHandler? permissionHandler,
    required JsonSchema? resourceSchemaOnUpdate,
  }) {
    var basePer = permissionHandler;
    var hasSchema = createSchema != null ||
        updateSchema != null ||
        resourceSchemaOnUpdate != null;
    PermissionHandler? schema;
    if (hasSchema) {
      schema = PermissionHandler._schema(
          updateSchema: updateSchema,
          createScheme: createSchema,
          onUpdateResource: resourceSchemaOnUpdate);
    }
    if (basePer == null && schema == null) return null;
    return PermissionHandler.merge(
        [if (basePer != null) basePer, if (schema != null) schema]);
  }

  ///
  final bool hasSchema;

  ///
  final String collectionName;

  ///
  final String? identifier;

  ///
  final List<Trigger>? triggers;

  ///
  final PermissionHandler? permissionHandler;
}

