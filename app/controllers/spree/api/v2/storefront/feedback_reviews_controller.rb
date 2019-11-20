module Spree
  module Api
    module V2
      module Storefront
        class FeedbackReviewsController < ::Spree::Api::V2::BaseController
          include Spree::Api::V2::CollectionOptionsHelpers

          before_action :sanitize_rating
          before_action :load_review
 
          def create
            require_spree_current_user unless !Spree::Reviews::Config[:require_login]

            feedback_review_params = {
              user: spree_current_user,
              review: @review,
              feedback_review_params: {
                comment: params[:comment],
                rating: params[:rating]
              }
            }

            result = create_service.call(feedback_review_params)

            if result.success?
              render_serialized_payload(201) { serialize_resource(result.value) }
            else
              render_error_payload(result.error)
            end
          end

          private
          # THIS HAS BEEN MOVED TO BASE CONTROLLER
          def serialize_resource(resource)
            if version >= Gem::Version.new('4.0')
              super
            else
              resource_serializer.new(
                resource,
                include: resource_includes,
                fields: sparse_fields
              ).serializable_hash
            end
          end

          def resource
            Spree::FeedbackReview.find(params[:id])
          end

          def resource_serializer
            Spree::V2::Storefront::FeedbackReviewSerializer
          end

          def create_service
            Spree::Reviews::Config[:storefront_feedback_review_create_service].constantize
          end

          def load_review
            @review ||= Spree::Review.find_by_id!(params[:review_id]) unless params[:review_id].nil?
          end
        
          def version
            @version ||= Gem.loaded_specs["spree_api"].version.release
          end

          def sanitize_rating
            params[:rating].to_s.sub!(/\s*[^0-9]*\z/, '') unless params[:rating].nil?
          end

        end
      end
    end
  end
end
