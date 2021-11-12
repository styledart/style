# SimpleAccessPoint

It is used to directly access a database with a ready-made query structure like REST.

In accordance with REST API standards, CRUD operations are implemented according to Http Methods (
GET,POST,DELETE,PUT,PATCH).

It uses data access in its context.

Supported by each operation resource (http,ws,internal).

## CRUD

Put component once

```dart
Component build(BuildContext context) {
  return Server(
      children: [
        SimpleAccessPoint("api")
      ]
  );
}
```

Now `www.example.com/api/..` calls will be handled by ``SimpleAccessPoint``.

### Create

Method: **POST**
Path: **../collection**

Example:

```
POST "www.example.com/users"
headers: {
	Content-type: application/json,
	Authorization: [token] // optional
}
body: {
	"user_id": "1a6wd1a3w8681",
	"user_name": "Mehmet",
	"user_last_name": "Yaz",
}
// Responded Without Body
headers: {
	Location: 1a6wd1a3w8681
}
status code: 201|403|500
```

### Read

#### Read Once

Method: **GET**
Path: **../collection/identifier**
*can define unique field with `identifierMapper` parameter. Default unique field is "id"*
Example:

```dart
SimpleAccessPoint(
  "api",
  identifierMapper: {
    "users" : "user_id"
  }
)
```

*If the unique field of the requested collection If it's "id", it's not needed.*

```
GET "www.example.com/users/1a6wd1a3w8681"
headers: {
	Authorization: [token] // optional
}
// Responded With Body
status code: 200|403|500
response body: {
	"user_id": "1a6wd1a3w8681",
	"user_name": "Mehmet",
	"user_last_name": "Yaz",
}
```

#### Read Multiple

For short queries (<1024 character)
Method: **GET**
Path: **../collection?l={limit}&s={skip}&q={query}**
Path: **../collection**
***Default limit is 200 , skip is 0***
Example:

```
GET "www.example.com/users?q={eq: {"user_id","1a6wd1a3w8681"}}"
// so: users?q=%7B%22user_id%22:%221a6wd1a3w8681%22%7D
headers: {
	Authorization: [token] // optional
}
// Responded With Body
status code: 200|403|500
response body: {
	"user_id": "1a6wd1a3w8681",
	"user_name": "Mehmet",
	"user_last_name": "Yaz",
}
```

***query selector***


### UPDATE

For create(if not exists) or override Method: **PUT**
Path: **../collection/identifier**

Example:

```
PUT"www.example.com/users/1a6wd1a3w8681"
headers: {
	Content-type: application/json,
	Authorization: [token] // optional
}
body: {
	"user_id": "1a6wd1a3w8681",
	"user_name": "Mehmet",
	"user_last_name": "Yaz",
}
// Responded With Body if created
headers: {
	Location: 1a6wd1a3w8681
}
status code: 200|201|403|500
```

Method: **PATCH**
Path: **../collection/identifier**

Example:

```
PATCH "www.example.com/users/1a6wd1a3w8681"
headers: {
	Content-type: application/json,
	Authorization: [token] // optional
}
body: {
	"user_name": "Mehmett",
}
// Responded Without Body
status code: 200|403|500
```

### Delete

Method: **DELETE**
Path: **../collection/identifier**

Example:

```
DELETE "www.example.com/users/1a6wd1a3w8681"
headers: {
	Content-type: application/json,
	Authorization: [token] // optional
}
// Responded Without Body
status code: 200|404
```

## Query

https://docs.mongodb.com/manual/tutorial/query-documents/

Operations use the following query structure.