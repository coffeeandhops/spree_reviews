module Spree::Api::V2::Storefront
  module Review
    class Create
      prepend Spree::ServiceModule::Base

      def call(user:, product:, review_params:)
        review_params[:user_id] = user.id
        review_params[:product_id] = product.id if !product.nil?
        review = Spree::Review.new(review_params)
        return failure(review) unless review.save
        success(review)
      end

    end
  end
end
