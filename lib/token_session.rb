# Signed token session middleware
#
# This session middleware stores the session data in a string with a
# cryptographic signature. This session manager is meant to be used for APIs,
# and one of the Rack::Session middleware options is probably more appropriate
# for most sites.
#
# Unlike typical session middlewares, the session content is not automatically
# stored or sent to the user. It is the responsibility of the developer to send
# the token to the client (by calling the {#to_s} method). The content of the
# session is in no way hidden from the client (the token is just the session
# data in JSON). It is however signed to prevent clients from forging a
# session.
#
# By default, the client will have to send the session token back to the server
# in the "X-Token" header.
#
# Other than the differences involving sending the session token to and from
# the client, the session object itself is available from "rack.session" in the
# request environment and acts like a Hash with a few methods added (see
# {Session} for details).
class TokenSession

  DEFAULT_OPTIONS = {
    key: 'rack.session',
    header: 'X-Token'
  }

  # A new instance of TokenSession
  #
  # Other than the 'key' and 'header' options, all keyword options will be
  # passed on to the {Session} class when it is instantiated.
  #
  # @param app [Object] Rack middleware or application
  # @param options [Hash]
  # @option options [String] :secret Required secret key used to sign tokens
  # @option options [String] :key ('rack.session') Key to store session under
  #   in environment
  # @option options [String] :header ('X-Token') Request header to load token
  #   from
  # @raise [ArgumentError] if no secret is provided
  def initialize(app, options={})
    @app = app

    @options = self.class::DEFAULT_OPTIONS.merge(options)
    @secret = @options[:secret]
    @key = @options.delete(:key)
    @header = @options.delete(:header)

    if @secret.nil? || @secret.empty?
      raise ArgumentError.new('no secret provided for TokenSession')
    end
  end

  # Standard Rack middleware call method
  #
  # A {Session} instance will be created and stored in the provided key in the
  # environment ("rack.session" by default). Otherwise, this functions like a
  # typical Rack middleware call method.
  #
  # @param env [Hash] Rack request environment
  def call(env)
    @app.call(env.merge(@key => self.session(env)))
  end

  # Create the {Session} instance for a request
  #
  # Creates the session from the provided request header. The session will be
  # reset if it is not valid (see the {Session#valid?} and {Session.reset!}
  # methods for more detail).
  #
  # @param env [Hash] Rack request environment
  # @return [Session]
  def session(env)
    session = Session.new(self.token(env), @options)
    session.reset! unless session.valid?
    session
  end

  # Retrieve the session token from request header
  #
  # @param env [Hash] Rack request environment
  # @return [String]
  def token(env)
    env[@header]
  end

end

require 'token_session/session'
