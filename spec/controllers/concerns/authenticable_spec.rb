require 'spec_helper'

class Authentication
  include Authenticable
  def request; end

  def response; end
end

describe Authenticable do
  let(:authentication) { Authentication.new }
  subject { authentication }

  describe '#current_user' do
    before do
      @user = FactoryBot.create :user
      request.headers['Authorization'] = @user.auth_token
      allow(authentication).to receive(:request) { request }
    end

    it 'returns the user from the authorization header' do
      expect(authentication.current_user.auth_token).to eql @user.auth_token
    end
  end

  describe '#authenticate with token' do
    before do
      @user = FactoryBot.create :user
      allow(authentication).to receive(:current_user) { nil }
      allow(response).to receive(:response_code) { 401 }
      allow(response).to receive(:body) { { errors: 'Not authenticated' }.to_json }
      allow(authentication).to receive(:response) { response }
    end

    it 'render a json error message' do
      expect(json_response[:errors]).to eql 'Not authenticated'
    end

    it { should respond_with 401 }
  end

  describe '#user_signed_in?' do
    context "when there is a user on 'session'" do
      before do
        @user = FactoryBot.create :user
        allow(authentication).to receive(:current_user) { @user }
      end

      it { should be_user_signed_in }
    end

    context "when there is no user on 'session'" do
      before do
        @user = FactoryBot.create :user
        allow(authentication).to receive(:current_user) { nil }
      end

      it { should_not be_user_signed_in }
    end
  end
end
