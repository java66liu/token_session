[![Build Status](https://travis-ci.org/javallone/token_session.png)](https://travis-ci.org/javallone/token_session)

# THIS GEM IS NOT PRODUCTION READY

I am **not** a security expert, but I know enough to say that I very well may
have done something that makes this implementation vulnerable. Since this code
may be insecure (or just a bad idea to begin with), I would suggest any
developers not use it (or at least be wary of it).

If you are someone who is able to confidently review what I've done and tell me
if/how I screwed up the crypto aspects of this code, I would like to hear from
you.

Until I am more confident of this code being both secure and not a crazy idea,
I am not going to do a proper gem build.

# TokenSession

TokenSession is a Rack session middleware. While session middleware typically
stores the session data in either a cookie or a backend service (database,
key-value store, etc), TokenSession stores the session data in a signed string.

This session middleware is targeted at API development. Using a session that
stores the data on a backend service creates added load on the API's servers,
and using a cookie-based session is inadvisable for security reasons. By
passing the session token manually in an HTTP header, these security issues are
averted.

OpenSSL's HMAC-SHA1 is used to sign the token. This prevents a client from
forging a session token without access to the server's secret.

## Installation

Add this line to your application's Gemfile:

    gem 'token_session'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install token_session

## Usage

1.  Create an instance of the TokenSession and add it to the middleware stack.
    You will most likely want to replace your existing session middleware at
    this time, but TokenSession can also be configured to work alongside other
    session middleware.
2.  When the session data is changed on the server, send the token to the
    client by calling

        env['rack.session'].to_s

    This will return the session token and can be passed to the client.
3.  When making a request, clients will have to provide the session token in the
    "X-Token" request header.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
