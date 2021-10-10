# Exception Handling With Style

I will share the developments related to the style backend framework, which I have announced in the
article( https://medium.com/me/stats/post/d544bdb78a36 ), in a series. If you have no idea about
style or don't understand the components in the examples below, please take a look at the main
article. You can subscribe to the medium account by e-mail to follow the developments. I will not
add an article on a topic other than this series and style and all is free-read. This series can be thought of as a
developer blog. For this reason, I will share developments are added. The subject context expected
from a documentation should not be expected from this series.

As it is known, a backend can receive many unexpected requests while runtime. These unexpected
requests and transactions are handled and the error message is sent to the client. These may be
developer-related(e.g. wrong type cast), or they may be Exceptions(Unauthorized request) that are expected to occur at runtime.

First of all, in order to minimize unexpected errors in style, errors originating from the component
tree are taken during the first run of the server. The program will stop because these errors are
not handled.

The `Wrapper` and `Route` topics in my main article are important to explain this topic.


```dart

```



