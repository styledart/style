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

import 'access_language.dart';
import 'access_object.dart';

///
abstract class UpdateData<L extends AccessLanguage> with AccessObject {


  ///
  Map<String, List<UpdateDifference>> differences();

}

///
abstract class UpdateDifference {
  ///
  UpdateDifference(this.key);

  ///
  String key;
}

///
class SetFieldsDifference<T> extends UpdateDifference {
  ///
  SetFieldsDifference(super.key, this.newValue);

  ///
  T newValue;

}
