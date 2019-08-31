require 'rails_helper'

describe Order, type: :model do
  let(:order) { FactoryBot.build :order }
  subject { order }

  it { should respond_to(:total) }
  it { should respond_to(:user_id) }

  it { should validate_presence_of :user_id }
  it { should validate_presence_of :total }
  it { should validate_numericality_of(:total).is_greater_than_or_equal_to(0) }

  it { should belong_to :user }
  it { should have_many :placements }
  it { should have_many(:products).through(:placements) }

  describe '#set_total!' do
    before(:each) do
      product1 = FactoryBot.create :product, price: 50
      product2 = FactoryBot.create :product, price: 80

      @order = FactoryBot.build :order, product_ids: [product1.id, product2.id]
    end

    it 'returns the total amount to pay for the products' do
      expect { @order.set_total! }.to change{ @order.total }.from(0).to(130)
    end
  end
end
