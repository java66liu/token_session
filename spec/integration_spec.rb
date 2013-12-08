require 'spec_helper'

describe 'TokenSession integration' do

  let(:app) do
    lambda { |env|
      [200, env, ['app']]
    }
  end

  let(:middleware) do
    TokenSession.new(app, secret: 'TEST SECRET')
  end

  let(:request) do
    Rack::MockRequest.new(middleware)
  end

  let(:response) do
    request.get('http://example.com/', 'X-Token' => token.to_s)
  end

  let(:token) { TokenSession::Session.new(nil, secret: 'TEST SECRET') }

  subject do
    response.headers['rack.session']
  end

  shared_examples_for :a_token_session do

    it { should be_a TokenSession::Session }

  end

  context 'no session data is provided' do

    let(:response) do
      request.get('http://example.com/')
    end

    it_behaves_like :a_token_session

    it { should == {} }

  end

  context 'valid session data is provided' do

    before(:each) do
      token[:test] = 'example'
    end

    it_behaves_like :a_token_session

    it { should == { test: 'example' } }

  end

  context 'invalid session data is provided' do

    let(:token) { TokenSession::Session.new(nil, secret: 'INVALID SECRET') }

    before(:each) do
      token[:test] = 'example'
    end

    it_behaves_like :a_token_session

    it { should_not == { test: 'example' } }

    it { should == {} }

  end

end
