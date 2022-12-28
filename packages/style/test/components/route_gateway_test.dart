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

import 'package:style_dart/style_dart.dart';
import 'package:style_test/style_test.dart';

void main() async {
  //    <suite duration="83" status="passed">
  //         <test duration="20" "init" status="passed"/>
  //         <suite duration="63" "route" status="passed">
  //             <test duration="9" "testing: /a/1" status="passed"/>
  //             <test duration="2" "gate1-1" status="passed"/>
  //             <test duration="1" "testing: /a/1/11" status="passed"/>
  //             <test duration="1" "gate1-2" status="passed"/>
  //             <test duration="1" "testing: /a/1/12" status="passed"/>
  //             <test duration="1" "gate1-3" status="passed"/>
  //             <test duration="2" "testing: /a/2" status="passed"/>
  //             <test duration="1" "testing: /a/2/21" status="passed"/>
  //             <test duration="1" "gate1-3" status="passed"/>
  //             <test duration="4" "testing: /3" status="passed"/>
  //             <test duration="0" "gate3" status="passed"/>
  //             <test duration="1" "testing: /3/31" status="passed"/>
  //             <test duration="0" "gate3-2" status="passed"/>
  //             <test duration="1" "testing: /3/32" status="passed"/>
  //             <test duration="1" "gate3-3" status="passed"/>
  //             <test duration="2" "testing: /4" status="passed"/>
  //             <test duration="2" "gate4-1" status="passed"/>
  //             <test duration="2" "testing: /4/41" status="passed"/>
  //             <test duration="2" "gate4-2" status="passed"/>
  //             <test duration="1" "testing: /5" status="passed"/>
  //             <test duration="0" "gate5-1" status="passed"/>
  //             <test duration="0" "testing: /5/51" status="passed"/>
  //             <test duration="0" "gate5-2" status="passed"/>
  //             <test duration="0" "testing: /6" status="passed"/>
  //             <test duration="2" "gate6-1" status="passed"/>
  //             <test duration="2" "testing: /6/61" status="passed"/>
  //             <test duration="11""gate6-2" status="passed"/>
  //             <test duration="5" "testing: /7" status="passed"/>
  //             <test duration="3" "testing: /7/71" status="passed"/>
  //             <test duration="2" "testing: /8" status="passed"/>
  //             <test duration="3" "testing: /8/81" status="passed"/>
  //         </suite>
  //     </suite>

  var gate1 = 0;
  var gate32 = 0;
  var gate3 = 0;
  var gate3And4 = 0;
  var gate5 = 0;
  var gate61 = 0;
  await initStyleTester(
      'route',
      Server(children: [
        /// for Route->Gateway
        /// and Gateway->Route
        Route('a',
            child: Gateway(children: [
              Gate(
                  child: Route('1',
                      root: SimpleEndpoint.static('1r'),
                      child: Gateway(children: [
                        Route('11', root: SimpleEndpoint.static('11')),
                        Route('12', root: SimpleEndpoint.static('12'))
                      ])),
                  onRequest: (r) {
                    gate1++;
                    return r;
                  }),
              Route('2',
                  root: SimpleEndpoint.static('2r'),
                  child: Route('21', root: SimpleEndpoint.static('21')))
            ])),

        /// for Gateway->Gateway
        /// and Gateway->SubRoute
        Gate(
            child: Gateway(children: [
              Gate(
                  child: Route('3',
                      child: Gateway(children: [
                        Route('31', root: SimpleEndpoint.static('31')),
                        Gate(
                            child:
                                Route('32', root: SimpleEndpoint.static('32')),
                            onRequest: (r) {
                              gate32++;
                              return r;
                            })
                      ])),
                  onRequest: (r) {
                    gate3++;
                    return r;
                  }),
              Route('4',
                  root: SimpleEndpoint.static('4r'),
                  child: Route('41', root: SimpleEndpoint.static('41')))
            ]),
            onRequest: (r) {
              gate3And4++;
              return r;
            }),

        /// for Gateway->Gateway->Gateway->SubRoute
        Gateway(children: [
          Gateway(children: [
            Gate(
                child: Route('5',
                    root: SimpleEndpoint.static('5r'),
                    child: Route('51', root: SimpleEndpoint.static('51'))),
                onRequest: (r) {
                  gate5++;
                  return r;
                }),
            Gateway(children: [
              Route('6',
                  root: SimpleEndpoint.static('6r'),
                  child: Route('61',
                      root: Gate(
                          child: SimpleEndpoint.static('61'),
                          onRequest: (r) {
                            gate61++;
                            return r;
                          }))),
              Gateway(children: [
                Route('7',
                    root: SimpleEndpoint.static('7r'),
                    child: Route('71', root: SimpleEndpoint.static('71'))),
                Route('8',
                    root: SimpleEndpoint.static('8r'),
                    child: Route('81', root: SimpleEndpoint.static('81')))
              ]),
            ])
          ])
        ])
      ]), (tester) async {
    /// /a/1
    /// /a/1/11
    /// /a/1/12
    /// the gate triggered on all
    tester('/a/1', bodyIs('1r'));
    test('gate1-1', () {
      expect(gate1, 1);
    });
    tester('/a/1/11', bodyIs('11'));
    test('gate1-2', () {
      expect(gate1, 2);
    });
    tester('/a/1/12', bodyIs('12'));
    test('gate1-3', () {
      expect(gate1, 3);
    });

    /// /a/2
    /// /a/21
    /// Any gate triggered
    tester('/a/2', bodyIs('2r'));
    tester('/a/2/21', bodyIs('21'));
    test('gate1-3', () {
      expect(gate1, 3);
    });

    /// /3  - 404
    /// /3/31
    /// /3/32 - gate32 triggered
    /// gate3and4 and gate3 triggered on all
    tester('/3', statusCodeIs(404));
    test('gate3', () {
      expect(gate3And4, 1);
      expect(gate3, 1);
    });
    tester('/3/31', bodyIs('31'));
    test('gate3-2', () {
      expect(gate3And4, 2);
      expect(gate3, 2);
    });

    tester('/3/32', bodyIs('32'));
    test('gate3-3', () {
      expect(gate3And4, 3);
      expect(gate3, 3);
      expect(gate32, 1);
    });

    /// /4
    /// /4/41
    /// gate3and4 triggered on all
    tester('/4', bodyIs('4r'));
    test('gate4-1', () {
      expect(gate3And4, 4);
    });
    tester('/4/41', bodyIs('41'));
    test('gate4-2', () {
      expect(gate3And4, 5);
    });

    /// /5
    /// /5/51
    tester('/5', bodyIs('5r'));
    test('gate5-1', () {
      expect(gate5, 1);
    });
    tester('/5/51', bodyIs('51'));
    test('gate5-2', () {
      expect(gate5, 2);
    });

    /// /6
    /// /6/61
    tester('/6', bodyIs('6r'));
    test('gate6-1', () {
      expect(gate61, 0);
    });
    tester('/6/61', bodyIs('61'));
    test('gate6-2', () {
      expect(gate61, 1);
    });

    /// /7
    /// /7/71
    tester('/7', bodyIs('7r'));
    tester('/7/71', bodyIs('71'));

    /// /8
    /// /8/81
    tester('/8', bodyIs('8r'));
    tester('/8/81', bodyIs('81'));

    ///
  });
}

class RouteExample extends StatelessComponent {
  ///
  const RouteExample({Key? key}) : super(key: key);

  @override
  Component build(BuildContext context) => Server(children: [
      Route('a',
          child: Gateway(children: [
            Route('1',
                root: SimpleEndpoint.static('1r'),
                child: Gateway(children: [
                  Route('11', root: SimpleEndpoint.static('11')),
                  Route('12', root: SimpleEndpoint.static('12'))
                ])),
            Route('2',
                root: SimpleEndpoint.static('2r'),
                child: Route('21', root: SimpleEndpoint.static('21')))
          ])),
      Gate(
          child: Gateway(children: [
            Gate(
                child: Route('3',
                    root: SimpleEndpoint.static('3r'),
                    child: Gate(
                        child: Route('31', root: SimpleEndpoint.static('31')),
                        onRequest: (r) {
                          print('only 31');
                          return r;
                        })),
                onRequest: (r) {
                  print('only 3');
                  return r;
                }),
            Route('4',
                root: SimpleEndpoint.static('4r'),
                child: Route('41', root: SimpleEndpoint.static('41')))
          ]),
          onRequest: (r) {
            print('3 ve 4');
            return r;
          }),
      Gateway(children: [
        Gate(
            child: Route('5',
                root: SimpleEndpoint.static('5r'),
                child: Route('51', root: SimpleEndpoint.static('51'))),
            onRequest: (r) {
              print('path 5');
              return r;
            }),
        Route('6',
            root: SimpleEndpoint.static('6r'),
            child: Route('61',
                root: Gate(
                    child: SimpleEndpoint.static('61'),
                    onRequest: (r) {
                      print('Path 61');
                      return r;
                    })))
      ])
    ]);
}
