class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :created_at, :updated_at, :product_ids

  def product_ids
    object.products.pluck('id')
  end
end
