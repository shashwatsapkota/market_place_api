require 'rails_helper'

RSpec.describe User, type: :model do
  before { @user = FactoryBot.build(:user) }

  subject { @user }

  it { should respond_to(:email) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should validate_presence_of(:email) }
  # it { should validate_uniqueness_of(:email) }
  it { should validate_confirmation_of(:password) }
  it { should allow_value('example@domain.com').for(:email) }
  it { should be_valid }

  it { should respond_to(:auth_token) }
  it { should validate_uniqueness_of(:auth_token) }

  it { should have_many(:products) }
  it { should have_many(:orders) }

  describe '#generate_authentication_token!' do
    it 'generates a unique token' do
      # Devise.stub(:friendly_token).and_return('auniquetoken123')
      allow(Devise).to receive(:friendly_token) { 'auniquetoken123' }
      @user.generate_authentication_token!
      expect(@user.auth_token).to eql 'auniquetoken123'
    end

    it 'generates another token when one has already been taken' do
      existing_user = FactoryBot.create(:user, auth_token: 'auniquetoken123')
      existing_user.generate_authentication_token!
      expect(existing_user.auth_token).not_to eql 'auniquetoken123'
    end
  end

  describe '#products association' do
    before do
      @user.save
      3.times { FactoryBot.create(:product, user: @user) }
    end

    it 'destroys the associated products on self destruct' do
      products = @user.products
      @user.destroy
      products.each do |product|
        expect(Product.find(product)).to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
