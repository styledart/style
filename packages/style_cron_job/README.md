
Style Cron Job is periodic operations executor and definator with basic syntax. You can define a period and run your process with your own executor or through the controller.

## Features

For the second, minute, hour, day, week, and month timepieces, you can specify periods such as "Each x in y time" or "Every x , in y time".

It has a simple syntax, close to spoken language.
Like this:
```dart
each.day.atHour(10).atMinute(20);
every.x(1).day.atHour(10).atMinute(20);
```
Both are mean "each day 10:20:00".

#### How does it work?
It basically uses the mechanism of checking once per second with Stream.periodic . Checks if it is necessary. If necessary, the process is started. Every checking is small process in ends with ~0.0012 ms (60k check in 77ms)

It was necessary to check every second for less ram consumption than Future.delayed or Timer until the next time, which is other methods.

Moreover, multiple cron jobs can be run on a single Stream.periodic.


#### Additional condition
Can define additional condition like,
```dart
each.day.atHour(10).atMinute(20).only((time) {  
  return time.weekday != 7; // except sunday
});
```



## Getting started

### 1 ) Define Period
There are 2 different options to start defining a period: `each` , `every`.

`each` is used for each month, week, day, hour, minute and second.
`every` is used for needs such as once every 3 days, once every 2 months.

```dart
each.**
every.x(3).**
```
`**` must be `month`, `week` , `day` , `hour` , `minute`, `second` for both,

#### Specify run time in sub time segments
For example "each day at 10:20:30"
```dart
each.day.atHour(10).atMinute(20).atSecond(30);
```
Default `hour` , `minute` and `second` is `0`.
Default `weekday` , `day`  is `1`.

*`at*` subsegments can be used sequentially*

#### Generated sub time segments

You can use subsegments of a certain time.

```dart
each.day.fromNowOn(DateTime.now());
each.day.fromNowOn(); // default DateTime.now()
```



### 2) Start

#### Listen
```dart
var period = each.day.onMinute(10);
period.listen((t) {  
    // do on each day 00:10
});
period.dispose();
```

#### Stream

```dart
var stream = each.minute.fromNowOn().asStream();
// eg starting 00:10:38
stream.listen((time){
	// Do on each minute on 38. second
});
// Don't forget
stream.cancel();
```

#### Controller
Controller manages all operations with a single stream. So this is the most effective type of use.
```dart
var runner = CronJobController();
runner.add(each.second.asRunner((time) {  
  // Do on each second
}));
runner.add(every.x(10).second.asRunner((time) {  
  // Do on every 10 seconds
}));

// Start
runner.start();
```

#### Custom
You can check period for necessary calling with time.
```dart
	var period = each.second.period;
	var necessary = period.isNecessary(DateTime.now());
	if (necessary) {
		// Do
	}
```


## Usage Examples

Each Week on Saturday at 23:45 (11:45 PM)
```dart
each.week.onWeekDay(6).atHour(23).atMinute(45);
```
---
Each Week on Monday at 09:00
```dart
each.week.onWeekDay(1).atHour(9);
```
---
Each Month on 15th at 09:00
```dart
each.month.onDay(15).atHour(9);
```
---
Once of every 3 days at 00:00:59
```dart
every.x(3).day.atSecond(59);
```

