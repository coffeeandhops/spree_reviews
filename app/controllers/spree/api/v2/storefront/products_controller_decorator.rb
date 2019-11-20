module Spree::Api::V2::Storefront::ProductsControllerDecorator

  private
  def scope_includes
    {
      master: :default_price,
      variants: [],
      variant_images: [],
      taxons: [],
      product_properties: :property,
      option_types: :option_values,
      variants_including_master: %i[default_price option_values],
      reviews: []
    }
  end
end
Spree::Api::V2::Storefront::ProductsController.prepend Spree::Api::V2::Storefront::ProductsControllerDecorator
