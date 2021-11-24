
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

#### ``statusCodeIsInRange(min,max)``

Check status code is in range.

Eg.
````dart
tester("/path/to", statusCodeIsInRange(200,300)); // max exclude
````

Simple range matchers:

- ``isInformational`` for informational status codes. (1**).
- ``isSuccess`` for success status codes (2**).
- ``isRedirection`` for redirection status codes. (3**).
- ``isClientError`` for client error status codes. (4**).
- ``isServerError`` for server error status codes. (5**).


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

// TODO: This documentation is a template.
