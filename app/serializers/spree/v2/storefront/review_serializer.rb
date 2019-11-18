module Spree
  module V2
    module Storefront
      class ReviewSerializer < BaseSerializer
        set_type   :review

        belongs_to :product
        belongs_to :user
        has_many   :feedback_reviews
      
        attributes :name, :review, :rating, :title, :location, :approved

      end
    end
  end
end
