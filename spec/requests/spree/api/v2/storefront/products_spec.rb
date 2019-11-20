require 'spec_api_helper'

describe 'API V2 Storefront Products Spec', type: :request do
  let!(:products)             { create_list(:product, 5) }
  let(:product)               { create(:product) }
  let!(:approved_review_1) { create(:review, product: products[0], approved: true, rating: 4) }
  let!(:approved_review_2) { create(:review, product: products[0], approved: true, rating: 5) }
  let!(:unapproved_review_1) { create(:review, product: products[0], approved: false, rating: 4) }

  describe 'products#index' do
    context 'with include reviews' do
      before { get "/api/v2/storefront/products?include=reviews" }

      it_behaves_like 'returns 200 HTTP status'

      it 'returns products with included approved reviews' do
        # pp json_response['included']
        expect(json_response['included']).to  include(have_type('review'))
        expect(json_response['included'].count).to  eq(2)
      end
    end
  end

  describe 'products#show' do
    context 'with non-existing product' do
      before { get '/api/v2/storefront/products/example' }

      it_behaves_like 'returns 404 HTTP status'
    end

    context 'with existing product' do
      before { get "/api/v2/storefront/products/#{product.slug}" }

      it_behaves_like 'returns 200 HTTP status'

      it 'returns a valid JSON response' do
        expect(json_response['data']).to have_attribute(:avg_rating).with_value(product.avg_rating.to_s)
        expect(json_response['data']).to have_attribute(:reviews_count).with_value(product.reviews_count)

        expect(json_response['data']).to have_relationships(
          :variants, :option_types, :product_properties, :default_variant, :reviews
        )
      end
    end
  end
end
