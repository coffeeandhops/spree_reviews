require 'spec_api_helper'

describe 'API V2 Storefront Reviews Spec', type: :request do
  # let!(:products)             { create_list(:product, 5) }
  let(:product)               { create(:product) }
  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let!(:approved_review_1) { create(:review, product: product, approved: true, rating: 4, user: user) }
  let!(:approved_review_2) { create(:review, product: product, approved: true, rating: 5, user: user) }
  let!(:approved_review_3) { create(:review, product: product, approved: true, rating: 5, user: user2) }
  let!(:approved_review_4) { create(:review, product: product, approved: true, rating: 5, user: user2) }
  let!(:unapproved_review_1) { create(:review, product: product, approved: false, rating: 4, user: user) }
  let(:review_params) {
    {
      product_id: product.id,
      title: "Best product Ever",
      review: "This is the best product ever because...",
      name: "John",
      rating: 5,
      location: "Here",
      show_identifier: false
    }
  }

  include_context 'API v2 tokens'

  describe 'reviews#index' do

    context 'with product_id' do
      # before { get "/api/v2/storefront/products/#{product.id}/reviews" }
      before { get "/api/v2/storefront/reviews?product_id=#{product.id}" }

      it_behaves_like 'returns 200 HTTP status'

      it 'returns reviews for the product' do
        expect(json_response['data'][0]).to have_relationships(:product, :user)
        expect(json_response['data'].count).to  eq(4)
      end
    end

    context 'for current_user' do
      let(:headers) { headers_bearer }

      before { get "/api/v2/storefront/reviews", headers: headers }

      it_behaves_like 'returns 200 HTTP status'

      it 'returns current user review' do
        expect(json_response['data'].count).to  eq(3)
      end
    end

    context 'for no user and no product_id' do
      let(:headers) { {} }

      before { get "/api/v2/storefront/reviews", headers: headers }

      it_behaves_like 'returns 403 HTTP status'
    end

  end

  describe 'reviews#show' do
    context 'with non-existing review' do
      before { get '/api/v2/storefront/reviews/999' }

      it_behaves_like 'returns 404 HTTP status'
    end

    context 'with approved review' do
      before { get "/api/v2/storefront/reviews/#{approved_review_1.id}" }

      it_behaves_like 'returns 200 HTTP status'

      it 'returns a valid JSON response' do
        expect(json_response['data']).to have_attribute(:title).with_value(approved_review_1.title)

        expect(json_response['data']).to have_relationships(
          :user, :product
        )
      end
    end

    context 'with non approved review for current user' do
      let(:headers) { headers_bearer }

      before { get "/api/v2/storefront/reviews/#{unapproved_review_1.id}", headers: headers }

      it_behaves_like 'returns 200 HTTP status'

      it 'returns a valid JSON response' do
        expect(json_response['data']).to have_attribute(:title).with_value(unapproved_review_1.title)
      end
    end

    context 'with non approved review for guest user' do
      let(:headers) { {} }

      before { get "/api/v2/storefront/reviews/#{unapproved_review_1.id}", headers: headers }

      it_behaves_like 'returns 403 HTTP status'
    end

  end

  describe 'reviews#create' do
    context 'for current_user' do
      let(:headers) { headers_bearer }

      before { post "/api/v2/storefront/reviews", headers: headers, params: review_params }

      it_behaves_like 'returns 201 HTTP status'

      it 'returns new review' do
        expect(json_response['data']).to have_attribute(:approved).with_value(false)
        expect(json_response['data']).to have_relationships(
          :user, :product
        )
      end

      context 'with blank rating' do
        let(:review_params) {
          {
            product_id: product.id,
            title: "Best product Ever",
            review: "This is the best product ever because...",
            name: "John",
            location: "Here",
            show_identifier: false
          }
        }

        before { post "/api/v2/storefront/reviews", headers: headers, params: review_params }

        it_behaves_like 'returns 422 HTTP status'

      end

      context 'with invalid product id' do
        let(:headers) { headers_bearer }

        let(:review_params) {
          {
            product_id: 999,
            title: "Best product Ever",
            review: "This is the best product ever because...",
            name: "John",
            rating: 5,
            location: "Here",
            show_identifier: false
          }
        }
        
        before { post "/api/v2/storefront/reviews", headers: headers, params: review_params }

        it_behaves_like 'returns 404 HTTP status'

      end


      context 'with missing product id' do
        let(:headers) { headers_bearer }

        let(:review_params) {
          {
            title: "Best product Ever",
            review: "This is the best product ever because...",
            name: "John",
            rating: 5,
            location: "Here",
            show_identifier: false
          }
        }
        
        before { post "/api/v2/storefront/reviews", headers: headers, params: review_params }

        it_behaves_like 'returns 422 HTTP status'

      end

    end

    context 'for guest user' do
      let(:headers) { {} }
      before { post "/api/v2/storefront/reviews", headers: headers, params: review_params }

      it_behaves_like 'returns 403 HTTP status'
    end


  end
end
