require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  describe 'Get #show' do
    before(:each) do
      @user = FactoryBot.create :user
      get :show, params: { id: @user.id }
    end

    it 'returns the information about a reporter on hash' do
      user_response = json_response
      expect(user_response[:user][:email]).to eql @user.email
    end

    it { should respond_with 200 }
  end

  describe 'POST #create' do
    context 'when successfully created' do
      before(:each) do
        @user_attributes = FactoryBot.attributes_for :user
        post :create, params: { user: @user_attributes }
      end

      it 'renders the json representation for the user record just created' do
        user_response = json_response
        expect(user_response[:email]).to eql @user_attributes[:email]
      end

      it { should respond_with 201 }
    end

    context 'when not created' do
      before(:each) do
        @invalid_user_attributes = { password: '12345678',
                                     password_confirmation: '123456789'
                                   }
        post :create, params: { user: @invalid_user_attributes }
      end

      it 'renders an error json' do
        user_response = json_response
        expect(user_response).to have_key(:errors)
      end

      it 'renders the json errors on why the user could not be created' do
        user_response = json_response
        expect(user_response[:errors][:email]).to eql ["can't be blank"]
      end

      it { should respond_with 422 }
    end
  end

  describe 'PUT/PATCH #update' do
    context 'when successfully updated' do
      before(:each) do
        @user = FactoryBot.create :user
        api_authorization_header(@user.auth_token)
        patch :update, params: { id: @user.id, user: { email: 'newmail@example.com' } }
      end

      it 'renders the json representation for the updated user' do
        user_response = json_response
        expect(user_response[:user][:email]).to eq 'newmail@example.com'
      end

      it { should respond_with 200 }
    end

    context 'when not created' do
      before(:each) do
        @user = FactoryBot.create :user
        api_authorization_header(@user.auth_token)
        patch :update, params: { id: @user.id, user: { email: 'bademail.com' } }
      end

      it 'renders an errors json' do
        user_response = json_response
        expect(user_response).to have_key(:errors)
      end

      it "renders the json error on why the user couldn't be created" do
        user_response = json_response
        expect(user_response[:errors][:email]).to include('is invalid')
      end

      it { should respond_with 422 }
    end
  end

  describe 'DELETE #destroy' do
    before(:each) do
      @user = FactoryBot.create :user
      api_authorization_header(@user.auth_token)
      delete :destroy, params: { id: @user.id }
    end

    it { should respond_with 204 }
  end
end
