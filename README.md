# Is Berlin happy today?

[![Build Status](https://travis-ci.org/jdennes/isberlinhappy.png?branch=master)](https://travis-ci.org/jdennes/isberlinhappy) [![Coverage Status](https://coveralls.io/repos/jdennes/isberlinhappy/badge.png?branch=master)](https://coveralls.io/r/jdennes/isberlinhappy)

The answer to the question of whether Berlin is [happy](http://whenyouliveinberlin.tumblr.com/post/44138613156/when-its-sunny-for-more-than-5-minutes) is closely related to the weather.

This phenomenon is probably true of most places in the world, but this little app is just for Berlin: http://isberlinhappytoday.com

Also, you can get the answer as JSON, by setting the `Accept` header value to `application/json` when making a request:

```sh
$ curl -H "Accept: application/json" "http://www.isberlinhappytoday.com"
{
   "happy": "Yes!",
   "text": "Mostly Cloudy",
   "temp" :16
}
```
