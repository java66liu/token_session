require 'delegate'
require 'openssl'
require 'json'

# Session object for the TokenSession
#
# This class delegates method calls to the Hash of session data. Any methods
# that are available for a Hash will work on this session.
#
# This class should not be instantiated directly (though it can be). To make
# use of a token session, add an instance of {TokenSession} to your middleware.
class TokenSession::Session < ::SimpleDelegator

  SIGNATURE_KEY = :__sig

  DEFAULT_OPTIONS = {
    digest: 'sha1'
  }

  # A new instance of Session
  #
  # @param token [String] Token from request headers
  # @param options [Hash]
  # @option options [String] :secret Required secret key used to sign tokens
  # @option options [String] :digest OpenSSL digest algorithm name to use for
  #   signing
  def initialize(token=nil, options={})
    super begin
      JSON.parse(token || '', symbolize_names: true)
    rescue JSON::ParserError
      {}
    end

    options = self.class::DEFAULT_OPTIONS.merge(options)
    @secret = options[:secret]
    @digest = options[:digest]
    @signature = self.delete(self.class::SIGNATURE_KEY)
  end

  # Clears all data from the session
  def reset!
    @signature = nil
    self.__setobj__({})
  end

  # Generates the HMAC signature for the current session data
  def signature
    data = JSON.generate(self)
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new(@digest), @secret, data)
  end

  # Check the validity of the session data
  #
  # Returns true if the session is signed and that signature is valid. A newly
  # created session will be marked as invalid (since it was not created with a
  # signature).
  #
  # @return [Boolean]
  def valid?
    if @signature.nil?
      return false
    end

    Rack::Utils.secure_compare(self.signature, @signature)
  end

  # Convert the session data to a string
  #
  # This will also sign the session and include the signature in the generated
  # JSON string.
  #
  # Use this method to send the session data to a client.
  #
  # @return [String]
  def to_s
    JSON.generate(self.merge(SIGNATURE_KEY => self.signature))
  end

end
