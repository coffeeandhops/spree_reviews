module Spree::Api::V2::Storefront
  module FeedbackReview
    class Create
      prepend Spree::ServiceModule::Base

      def call(user:, review:, feedback_review_params:)
        feedback_review_params[:user_id] = user.id if user
        feedback_review_params[:review_id] = review.id if !review.nil?
        feedback_review = Spree::FeedbackReview.new(feedback_review_params)
        return failure(feedback_review) unless feedback_review.save
        success(feedback_review)
      end

    end
  end
end
