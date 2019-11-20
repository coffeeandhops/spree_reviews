module Spree
  module V2
    module Storefront
      class FeedbackReviewSerializer < BaseSerializer
        set_type   :feedback_review

        belongs_to :review
        belongs_to :user
      
        attributes :rating, :comment

      end
    end
  end
end
