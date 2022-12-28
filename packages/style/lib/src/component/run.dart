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

part of '../style_base.dart';

///
Binding runService(Component component) {
  var binding = component.createBinding();
  binding.buildBinding();

  binding.visitChildren(TreeVisitor((visitor) {
    if (visitor.currentValue is ServiceWrapperBinding) {
      (visitor.currentValue as ServiceWrapperBinding).component.service._init();
    }
  }));

  // var runner = CommandRunner("style", "style inline command-line app");
  // runner.addCommand(SetProperty());
  //
  // stdin.listen((event) {
  //   runner.run(utf8.decode(event).split(" "));
  // });

  return binding;
}

// ///
// class SetProperty extends Command {
//
//   ///
//   SetProperty(){
//     argParser.addMultiOption("property",abbr: "p",callback: (v){
//
//     });
//   }
//
//
//   void run(){
//     if(argResults == null) {
//       return;
//     }
//
//     if (argResults!.rest.isEmpty) {
//       throw UsageException("state key not found", usage);
//     }
//
//   }
//
//   @override
//   String get description => "Set property of state";
//
//   @override
//   String get name => "set-property";
// }
