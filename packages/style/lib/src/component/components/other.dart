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

part of '../../style_base.dart';

///
class CallQueue extends SingleChildCallingComponent {
  ///
  CallQueue(this.child,
      {this.parallel = 1, this.timeout = const Duration(seconds: 10)})
      : super(child);

  ///
  final Component child;

  ///
  final int parallel;

  ///
  final Duration timeout;

  @override
  SingleChildCallingBinding createBinding() => SingleChildCallingBinding(this);

  @override
  Calling createCalling(covariant SingleChildCallingBinding context) =>
      _QueueCalling(context);
}

class _QueueCalling extends Calling {
  _QueueCalling(SingleChildCallingBinding binding) : super(binding);

  late q.Queue queue = q.Queue(
      parallel: (binding.component as CallQueue).parallel,
      timeout: (binding.component as CallQueue).timeout);

  @override
  SingleChildCallingBinding get binding =>
      super.binding as SingleChildCallingBinding;

  @override
  FutureOr<Message> onCall(Request request) async {
    return queue.add(() async => binding.child.findCalling.calling(request));
  }
}
