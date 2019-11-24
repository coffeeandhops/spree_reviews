module Spree
  module Api
    module V2
      module Storefront
        class ReviewsController < ::Spree::Api::V2::BaseController
          include Spree::Api::V2::CollectionOptionsHelpers
          before_action :load_product, only: [:index, :new, :create]
          before_action :sanitize_rating, only: [:create]
          
          def index
            render_serialized_payload { serialize_collection(paginated_collection) }
          end

          def show
            render_serialized_payload { serialize_resource(resource) }
          end

          def create
            require_spree_current_user unless !Spree::Reviews::Config[:require_login]

            review_params = {
              user: spree_current_user,
              product: @product,
              review_params: {
                title: params[:title],
                review: params[:review],
                name: params[:name],
                rating: params[:rating],
                location: params[:location],
                show_identifier: params[:show_identifier],
                ip_address: request.remote_ip
              }
            }

            result = create_service.call(review_params)

            if result.success?
              render_serialized_payload(201) { serialize_resource(result.value) }
            else
              render_error_payload(result.error)
            end
          end

          def setting
            render json: {
              data: {
                attributes: {
                  include_unapproved_reviews: Spree::Reviews::Config[:include_unapproved_reviews],
                  preview_size: Spree::Reviews::Config[:preview_size],
                  show_email: Spree::Reviews::Config[:show_email],
                  feedback_rating: Spree::Reviews::Config[:feedback_rating],
                  require_login: Spree::Reviews::Config[:require_login],
                  show_identifier: Spree::Reviews::Config[:show_identifier]
                }
              }
            }
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

          # THIS HAS BEEN MOVED TO BASE CONTROLLER
          def serialize_collection(collection)
            if version >= Gem::Version.new('4.0')
              super
            else
              collection_serializer.new(
                collection,
                collection_options(collection)
              ).serializable_hash
            end
          end
      
          # THIS HAS BEEN MOVED TO BASE CONTROLLER
          def collection_options(collection)
            if version >= Gem::Version.new('4.0')
              super
            else
              {
                links: collection_links(collection),
                meta: collection_meta(collection),
                include: resource_includes,
                fields: sparse_fields
              }
            end
          end

          def resource
            review = Spree::Review.find(params[:id])

            return review if Spree::Reviews::Config[:include_unapproved_reviews] || review.approved

            # allow admin or owner to get unapproved review
            require_spree_current_user
            
            return review if is_admin? || review.user_id == spree_current_user.id
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
              user: {},
              feedback_reviews: []
            }
          end

          def create_service
            Spree::Reviews::Config[:storefront_review_create_service].constantize
          end

          def paginated_collection
            collection_paginator.new(collection, params).call
          end

          def collection
            if @product
              return @product.reviews if is_admin?
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

          def version
            @version ||= Gem.loaded_specs["spree_api"].version.release
          end

          def is_admin?
            spree_current_user && spree_current_user.respond_to?(:has_spree_role?) && spree_current_user.has_spree_role?('admin')
          end

          def sanitize_rating
            params[:rating].to_s.sub!(/\s*[^0-9]*\z/, '') unless params[:rating].nil?
          end

        end
      end
    end
  end
end
