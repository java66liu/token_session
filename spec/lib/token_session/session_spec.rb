require 'spec_helper'

describe TokenSession::Session do

  describe '#initialize' do

    it 'parses the JSON token and delegates methods to it' do
      token_str = JSON.generate(example: 'testing')
      TokenSession::Session.new(token_str).should == { example: 'testing' }
    end

    it 'handles invalid JSON correctly' do
      TokenSession::Session.new('{').should == {}
    end

    it 'handles a nil token' do
      TokenSession::Session.new.should == {}
    end

    it 'removes the signature from the data' do
      token_str = JSON.generate(example: 'testing', __sig: 'signature')
      TokenSession::Session.new(token_str).should == { example: 'testing' }
    end

    it 'removes the created time from the data' do
      token_str = JSON.generate(example: 'testing', __created: Time.now.to_s)
      TokenSession::Session.new(token_str,
        expire_after: 1).should == { example: 'testing' }
    end

  end

  describe '#reset!' do

    subject do
      token_str = JSON.generate(example: 'testing', __sig: 'signature')
      TokenSession::Session.new(token_str)
    end

    it 'resets the session data' do
      subject.reset!
      subject.should == {}
    end

    it 'resets the signature from the token string' do
      subject.reset!
      subject.instance_variable_get(:@signature).should be_nil
    end

  end

  describe '#signature' do

    it 'generates an HMAC signature from the data' do
      OpenSSL::HMAC.should_receive(:hexdigest)
        .with(instance_of(OpenSSL::Digest), :secret, '{"example":"testing"}')
        .and_return(:signature)

      session = TokenSession::Session.new(nil, secret: :secret)
      session[:example] = 'testing'
      session.signature.should == :signature
    end

  end

  describe '#expired?' do

    let(:expire_after) do
      nil
    end

    let(:created_at) do
      Time.now.to_s
    end

    let(:token) do
      { __created: created_at }
    end

    let(:session) do
      TokenSession::Session.new(JSON.generate(token),
        expire_after: expire_after)
    end

    subject do
      session.expired?
    end

    context 'no expire_after option provided' do

      it { should == false }

    end

    context 'expire_after is provided and the token has not expired' do

      let(:created_at) do
        (Time.now - 60).to_s
      end

      let(:expire_after) do
        120
      end

      it { should == false }

    end

    context 'expire_after is provided and the token has expired' do

      let(:created_at) do
        (Time.now - 120).to_s
      end

      let(:expire_after) do
        60
      end

      it { should == true }

    end

  end

  describe '#valid?' do

    let(:token) do
      {}
    end

    let(:session) do
      session = TokenSession::Session.new(JSON.generate(token))
      session.stub(:signature).and_return('valid_signature')
      session.stub(:expired?).and_return(expired)
      session
    end

    let(:expired) do
      false
    end

    subject do
      session.valid?
    end

    context 'the token string is unsigned' do

      it { should == false }

    end

    context 'the token string is signed with a valid signature' do

      let(:token) do
        { __sig: 'valid_signature' }
      end

      it { should == true }

    end

    context 'the token string is signed with an invalid signature' do

      let(:token) do
        { __sig: 'invalid_signature' }
      end

      it { should == false }

    end

    context 'the token string is validly signed, but expired' do

      let(:token) do
        { __sig: 'valid_signature' }
      end

      let(:expired) do
        true
      end

      it {should == false }

    end

  end

  describe '#to_s' do

    let(:session) do
      session = TokenSession::Session.new
      session.stub(:signature).and_return('TESTING_SIG')
      session[:example] = 'testing'
      session
    end

    subject do
      session.to_s
    end

    it { should == JSON.generate(example: 'testing', __sig: 'TESTING_SIG') }

  end

end
