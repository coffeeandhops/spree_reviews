module Spree
  module Api
    module V2
      module Storefront
        class ReviewsController < ::Spree::Api::V2::BaseController
          include Spree::Api::V2::CollectionOptionsHelpers
          before_action :load_product, only: [:index, :new, :create]
          
          def index
            render_serialized_payload { serialize_collection(paginated_collection) }
          end

          def show
            render_serialized_payload { serialize_resource(resource) }
          end

          def create
            require_spree_current_user

            params[:rating] = params[:rating].sub!(/\s*[^0-9]*\z/, '') unless params[:rating].blank?
            review_params = {
              user: spree_current_user,
              product: @product,
              review_params: {
                title: params[:title],
                review: params[:review],
                name: params[:name],
                rating: params[:rating],
                location: params[:location],
                show_identifier: params[:show_identifier]
              }
            }

            result = create_service.call(review_params)

            if result.success?
              render_serialized_payload(201) { serialize_resource(result.value) }
            else
              render_error_payload(result.error)
            end
          end

          # def destroy
          #   require_spree_current_user
          #   spree_authorize! :delete, resource, spree_current_user
          #   review = resource
          #   delete_service.call(review: review)

          #   render_serialized_payload { serialize_resource(review) }
          # end

          private
          # # THIS HAS BEEN MOVED TO BASE CONTROLLER
          # def serialize_resource(resource)
          #   resource_serializer.new(
          #     resource,
          #     include: resource_includes,
          #     fields: sparse_fields
          #   ).serializable_hash
          # end

          # THIS HAS BEEN MOVED TO BASE CONTROLLER
          def serialize_collection(collection)
            collection_serializer.new(
              collection,
              collection_options(collection)
            ).serializable_hash
          end
      
          # THIS HAS BEEN MOVED TO BASE CONTROLLER
          def collection_options(collection)
            {
              links: collection_links(collection),
              meta: collection_meta(collection),
              include: resource_includes,
              fields: sparse_fields
            }
          end

          def resource
            review = Spree::Review.find(params[:id])

            return review if Spree::Reviews::Config[:include_unapproved_reviews] || review.approved

            # allow admin or owner to get unapproved review
            require_spree_current_user
            
            is_admin = spree_current_user.respond_to?(:has_spree_role?) && spree_current_user.has_spree_role?('admin')
            return review if is_admin || review.user_id == spree_current_user.id
          end

          def resource_serializer
            Spree::V2::Storefront::ReviewSerializer
          end

          def collection_serializer
            Spree::V2::Storefront::ReviewSerializer
          end

          def scope
            Spree::Review.accessible_by(current_ability, :show).includes(scope_includes)
          end

          def current_ability
            @current_ability ||= Spree::ReviewsAbility.new(spree_current_user)
          end

          def scope_includes
            {
              product: {},
              user: {}
            }
          end

          def create_service
            Spree::Api::V2::Storefront::Review::Create
          end

          # def delete_service
          #   Spree::Api::V2::Storefront::Review::Delete
          # end

          def paginated_collection
            collection_paginator.new(collection, params).call
          end

          def collection
            if @product
              return @product.reviews if spree_current_user && spree_current_user.role == "admin"
              return @product.public_reviews
            end

            require_spree_current_user
            Spree::Review.where(user_id: spree_current_user.id)
          end
  
          def collection_paginator
            Spree::Api::Dependencies.storefront_collection_paginator.constantize
          end

          def load_product
            @product = Spree::Product.friendly.find(params[:product_id]) if !params[:product_id].nil?
          end

        end
      end
    end
  end
end
