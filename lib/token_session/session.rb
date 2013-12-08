require 'delegate'
require 'openssl'
require 'json'

class TokenSession::Session < ::SimpleDelegator

  SIGNATURE_KEY = :__sig

  DEFAULT_OPTIONS = {
    digest: 'sha1'
  }

  def initialize(token_str=nil, options={})
    super begin
      JSON.parse(token_str || '', symbolize_names: true)
    rescue JSON::ParserError
      {}
    end

    options = self.class::DEFAULT_OPTIONS.merge(options)
    @secret = options[:secret]
    @digest = options[:digest]
    @signature = self.delete(self.class::SIGNATURE_KEY)
  end

  def reset!
    @signature = nil
    self.__setobj__({})
  end

  def signature
    data = JSON.generate(self)
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new(@digest), @secret, data)
  end

  def valid?
    if @signature.nil?
      return false
    end

    Rack::Utils.secure_compare(self.signature, @signature)
  end

  def to_s
    JSON.generate(self.merge(SIGNATURE_KEY => self.signature))
  end

end
