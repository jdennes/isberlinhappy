# Is Berlin happy today?

The answer to the question of whether Berlin is [happy](http://whenyouliveinberlin.tumblr.com/post/44138613156/when-its-sunny-for-more-than-5-minutes) is closely related to the weather.

This phenomenon is probably true of most places in the world, but this little app is just for Berlin: http://isberlinhappy.jdenn.es

You can get the answer as JSON, by setting the `Accept` header value to `application/json` when making a request:

```sh
$ curl -H "Accept: application/json" http://isberlinhappy.jdenn.es
{"happy":"Yes!","text":"Fair","temp_c":23,"temp_f":73}
```

[![Build Status](https://travis-ci.org/jdennes/isberlinhappy.svg?branch=master)](https://travis-ci.org/jdennes/isberlinhappy) [![Coverage Status](https://coveralls.io/repos/jdennes/isberlinhappy/badge.svg?branch=master)](https://coveralls.io/repos/jdennes/isberlinhappy/badge.svg?branch=master)
