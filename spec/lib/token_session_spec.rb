require 'spec_helper'

describe TokenSession do

  let(:session_double) do
    session = double(TokenSession::Session)
    session.stub(:valid?).and_return(true)
    session.stub(:reset!)
    session
  end

  before(:each) do
    TokenSession::Session.stub(:new).and_return(session_double)
  end

  describe '#initialize' do

    it 'raises an ArgumentError when the secret is nil' do
      lambda do
        TokenSession.new(nil, secret: nil)
      end.should raise_error(ArgumentError,
        'no secret provided for TokenSession')
    end

    it 'raises an ArgumentError when the secret is blank' do
      lambda do
        TokenSession.new(nil, secret: '')
      end.should raise_error(ArgumentError,
        'no secret provided for TokenSession')
    end

  end

  describe '#call' do

    let(:environment) do
      { example: 'testing' }
    end

    let(:app) do
      double('Application')
    end

    let(:environment_key) do
      'rack.session.testing'
    end

    let(:middleware) do
      TokenSession.new(app, secret: 'SAMPLE', key: environment_key)
    end

    it 'calls the application' do
      app.should_receive(:call)
        .with({ :example => 'testing', environment_key => session_double })
        .and_return(:result)

      middleware.call(environment).should == :result
    end

  end

  describe '#session' do

    before(:each) do
      TokenSession.any_instance.stub(:token).and_return(:token)
    end

    let(:environment) do
      :environment
    end

    let(:middleware) do
      TokenSession.new(nil, secret: 'SAMPLE')
    end

    subject do
      middleware.session(environment)
    end

    it { should == session_double }

    it 'constructs the Session with the #token and options' do
      TokenSession::Session.should_receive(:new)
        .with(:token, { secret: 'SAMPLE' })
        .and_return(session_double)
      subject
    end

    context 'the session is invalid' do

      before(:each) do
        session_double.stub(:valid?).and_return(false)
      end

      it 'resets the session' do
        session_double.should_receive(:reset!)
        subject
      end

    end

  end

  describe '#token' do

    let(:token_header) do
      'X-Token-Test'
    end

    let(:environment) do
      {}
    end

    let(:middleware) do
      TokenSession.new(nil, header: token_header, secret: 'SAMPLE')
    end

    subject do
      middleware.token(environment)
    end

    context 'the token header is provided' do

      let(:environment) do
        { 'X-Token-Test' => 'example' }
      end

      it { should == 'example' }

    end

    context 'the token header is not provided' do

      it { should be_nil }

    end

  end

end
