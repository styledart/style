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

///
class CacheOptions {
  ///
  CacheOptions(
      {this.forceNoCache = false,
      this.onlyMemoryCache = false,
      this.onlyDiskCache = false,
      this.customModifiedSince,
      this.customEtag})
      : assert(
            (!onlyMemoryCache && !onlyDiskCache) ||
                onlyDiskCache != onlyMemoryCache,
            "onlyMemoryCache and onlyDiskCache both must be false"
            " or only one is true");

  ///
  final bool forceNoCache;

  ///
  final bool onlyDiskCache;

  ///
  final bool onlyMemoryCache;

  ///
  final String? customEtag;

  ///
  final DateTime? customModifiedSince;
}
