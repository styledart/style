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
class CallTrigger extends SingleChildCallingComponent {
  ///
  CallTrigger(
      {required Component child,
      this.responseTrigger,
      this.requestTrigger,
      this.ensureResponded = false,
      this.ensureSent = false})
      : super(child);

  ///
  final void Function(Request request)? requestTrigger;

  /// Message maybe request or response
  final void Function(Message message)? responseTrigger;

  ///
  final bool ensureResponded;

  ///
  final bool ensureSent;

  @override
  SingleChildCallingBinding createBinding() => SingleChildCallingBinding(this);

  @override
  Calling createCalling(covariant SingleChildCallingBinding context) =>
      _CallTriggerCalling(context);
}

///
class _CallTriggerCalling extends Calling {
  _CallTriggerCalling(SingleChildCallingBinding binding) : super(binding);

  CallTrigger get component => binding.component as CallTrigger;

  @override
  SingleChildCallingBinding get binding =>
      super.binding as SingleChildCallingBinding;

  Future<void> _ensureResponded(Request request) async {
    var responded = await request.ensureResponded();
    if (responded) {
      component.requestTrigger!.call(request);
    }
  }

  Future<void> _ensureSent(Message message) async {
    var responded = message is Response && await message.ensureSent();
    if (responded) {
      component.responseTrigger!.call(message);
    }
  }

  @override
  FutureOr<Message> onCall(Request request) async {
    if (component.requestTrigger != null) {
      if (component.ensureResponded) {
        _ensureResponded(request);
      } else {
        component.requestTrigger!.call(request);
      }
    }
    if (component.responseTrigger != null) {
      var res = await binding.child.findCalling.calling(request);
      if (component.ensureSent) {
        _ensureSent(res);
      } else {
        component.responseTrigger!.call(request);
      }
      return res;
    } else {
      return binding.child.findCalling.calling(request);
    }
  }
}

///
class RequestTrigger extends StatelessComponent {
  ///
  const RequestTrigger(
      {required this.child,
      required this.trigger,
      this.ensureResponded = false,
      Key? key})
      : super(key: key);

  ///
  final void Function(Request request)? trigger;

  ///
  final Component child;

  ///
  final bool ensureResponded;

  @override
  Component build(BuildContext context) {
    return CallTrigger(
        child: child,
        requestTrigger: trigger,
        ensureResponded: ensureResponded);
  }
}

///
class ResponseTrigger extends StatelessComponent {
  ///
  const ResponseTrigger(
      {required this.child,
      required this.trigger,
      this.ensureSent = false,
      Key? key})
      : super(key: key);

  ///
  final void Function(Message message)? trigger;

  ///
  final Component child;

  ///
  final bool ensureSent;

  @override
  Component build(BuildContext context) {
    return CallTrigger(
        child: child, responseTrigger: trigger, ensureSent: ensureSent);
  }
}
