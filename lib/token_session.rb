class TokenSession

  DEFAULT_OPTIONS = {
    key: 'rack.session',
    header: 'X-Token'
  }

  def initialize(app, options={})
    @app = app

    @options = self.class::DEFAULT_OPTIONS.merge(options)
    @secret = @options[:secret]
    @key = @options.delete(:key)
    @header = @options.delete(:header)

    raise ArgumentError.new('no secret provided for TokenSession') if @secret.nil? || @secret.empty?
  end

  def call(env)
    @app.call(env.merge(@key => self.session(env)))
  end

  def session(env)
    session = Session.new(self.token(env), @options)
    session.reset! unless session.valid?
    session
  end

  def token(env)
    env[@header]
  end

end

require 'token_session/session'
