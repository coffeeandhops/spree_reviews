module Spree::V2::Storefront::ProductSerializerDecorator
  def self.prepended(base)
    base.has_many :reviews, object_method_name: :public_reviews
    base.attributes :avg_rating, :reviews_count
  end
end

Spree::V2::Storefront::ProductSerializer.prepend Spree::V2::Storefront::ProductSerializerDecorator
