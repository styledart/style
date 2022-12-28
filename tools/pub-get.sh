#
# Copyright 2021 styledart.dev - Mehmet Yaz
#
# Licensed under the GNU AFFERO GENERAL PUBLIC LICENSE,
#    Version 3 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       https://www.gnu.org/licenses/agpl-3.0.en.html
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#
cd ..

function pubGet() {
  echo "Running pub get for $1"
  cd "$1" || exit
  dart pub get
  cd ..
}

cd packages || exit
# shellcheck disable=SC2045
for dir in $(ls -d ./*/);
    do
      [[ -d "$dir" ]] || break
      if [[ $dir =~ .*object/$ ]]; then
          echo "Skipping $dir"
      else
          pubGet "$dir"
      fi
done

cd object || exit
# shellcheck disable=SC2045
for dir in $(ls -d ./*/); do
    pubGet "$dir"
done
