
//TODO: Template

## Features

Tester for Style framework

## Getting started

add latest version "style_test" to dev_dependencies

## Usage

Ensure main is async and await ``initStyleTester``

````dart
void main() async {
  await initStyleTester(
      "route",
      MyServer(),
          (tester) async {
        /// test /a/1
        tester("/a/1", bodyIs("1r"));
      });
}
````

### Matchers

#### ``bodyIs(matcherOrValue)``

Check body.

`matcherOrValue` can be ``matcher`` instance.

Eg.
````dart
tester("/path/to", bodyIs(contains("any")));
````


#### ``statusCodeIs(int)``

Check status code.

Eg.
````dart
tester("/path/to", statusCodeIs(200));
````

#### ``headerIs(key, value)``

Check headers.

Eg.
````dart
tester("/path/to", headerIs("Location","http://localhost/my_user1"));
````

#### ``permissionDenied``

````dart
tester("/path/to", permissionDenied);
````



#### ``isUnauthorized``

````dart
tester("/path/to", isUnauthorized);
````


## Additional information

TODO:
