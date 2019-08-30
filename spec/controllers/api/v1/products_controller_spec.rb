require 'rails_helper'

describe Api::V1::ProductsController, type: :controller do
  describe 'GET #show' do
    before(:each) do
      @product = FactoryBot.create :product
      get :show, params: { id: @product.id }
    end

    it 'returns the information about a reporter on a hash' do
      product_response = json_response
      expect(product_response[:product][:title]).to eql @product.title
    end

    it 'has the user as a embed object' do
      product_response = json_response[:product]
      expect(product_response[:user][:email]).to eql @product.user.email
    end

    it { should respond_with 200 }
  end

  describe 'GET #index' do
    before(:each) do
      4.times { FactoryBot.create :product }
      get :index
    end

    it 'returns 4 records from the database' do
      products_response = json_response
      expect(products_response[:products].size).to eq(4)
    end

    it 'returns the user object into each product' do
      products_response = json_response[:products]
      products_response.each do |product_response|
        expect(product_response[:user]).to be_present
      end
    end

    it { should respond_with 200 }
  end

  describe 'POST #create' do
    context 'when is successfully created' do
      before(:each) do
        user = FactoryBot.create :user
        @product_attributes = FactoryBot.create :product
        api_authorization_header user.auth_token
        post :create, params: { user_id: user.id, product: @product_attributes }
      end

      it 'renders the json representation of the product record just created' do
        product_response = json_response
        expect(product_response[:product][:title]).to eql @product_attributes[:title]
      end

      it { should respond_with 201 }
    end

    context 'when not created' do
      before(:each) do
        user = FactoryBot.create :user
        @invalid_product_attributes = { title: 'test product', price: 'Twelve dollars' }
        api_authorization_header user.auth_token
        post :create, params: { user_id: user.id, product: @invalid_product_attributes}
      end

      it 'renders an errors json' do
        product_response = json_response
        expect(product_response).to have_key(:errors)
      end

      it "renders the json error on why the user couldn't be created" do
        product_response = json_response
        expect(product_response[:errors][:price]).to include 'is not a number'
      end

      it { should respond_with 422 }
    end
  end

  describe 'PUT/PATCH #update' do
    before(:each) do
      @user = FactoryBot.create :user
      @product = FactoryBot.create :product, user: @user
      api_authorization_header @user.auth_token
    end

    context 'when is successfully updated' do
      before(:each) do
        patch :update, params: { user_id: @user.id, id: @product.id, product: { title: 'An expensive TV' } }
      end

      it 'renders the json representation for the updated user' do
        product_response = json_response
        expect(product_response[:product][:title]).to eql 'An expensive TV'
      end

      it { should respond_with 200 }
    end

    context 'when not updated' do
      before(:each) do
        patch :update, params: {user_id: @user.id, id: @product.id, product: { price: 'two hundred'} }
      end

      it 'renders an errors json' do
        product_response = json_response
        expect(product_response).to have_key(:errors)
      end

      it 'renders the errors on why product could not be updated' do
        product_response = json_response
        expect(product_response.dig(:errors, :price)).to include 'is not a number'
      end

      it { should respond_with 422 }
    end
  end

  describe 'DELETE #destroy' do
    before(:each) do
      @user = FactoryBot.create :user
      @product = FactoryBot.create :product, user: @user
      api_authorization_header @user.auth_token
      delete :destroy, params: { user_id: @user.id, id: @product.id }
    end

    it { should respond_with 204 }
  end
end
