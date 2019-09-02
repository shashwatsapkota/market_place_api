FactoryBot.define do
  factory :placement do
    order { nil }
    product
    quantity { 1 }
  end
end
