require 'spec_api_helper'

describe 'API V2 Storefront Reviews Spec', type: :request do
  # let!(:products)             { create_list(:product, 5) }
  let(:product) { create(:product) }
  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let!(:approved_review_1) { create(:review, product: product, approved: true, rating: 4, user: user) }
  let!(:approved_review_2) { create(:review, product: product, approved: true, rating: 5, user: user) }
  let!(:approved_review_3) { create(:review, product: product, approved: true, rating: 5, user: user2) }
  let!(:approved_review_4) { create(:review, product: product, approved: true, rating: 5, user: user2) }
  let!(:unapproved_review_1) { create(:review, product: product, approved: false, rating: 4, user: user) }
  let!(:feedback_review_1) { create(:feedback_review, created_at: 10.days.ago, review: approved_review_1) }
  let!(:feedback_review_2) { create(:feedback_review, created_at: 2.days.ago, review: approved_review_1) }
  let!(:feedback_review_3) { create(:feedback_review, created_at: 5.days.ago, review: approved_review_1) }

  let(:feedback_review_params) {
    {
      review_id: approved_review_1.id,
      comment: "Very helpful!",
      rating: 5,
    }
  }

  before do
    Spree::Reviews::Config[:require_login] = true
  end

  include_context 'API v2 tokens'

  describe 'feedback_reviews#create' do
    context 'for current_user' do
      
      let(:headers) { headers_bearer }

      before { post "/api/v2/storefront/feedback_reviews", headers: headers, params: feedback_review_params }
      it_behaves_like 'returns 201 HTTP status'

      it 'returns new review' do
        expect(json_response['data']).to have_attribute(:rating).with_value(5)
        expect(json_response['data']).to have_relationships(
          :user, :review
        )
      end

      context 'with blank rating' do
        let(:feedback_review_params) {
          {
            review_id: approved_review_1.id,
            comment: "Very helpful!"
          }
        }

        before { post "/api/v2/storefront/reviews", headers: headers, params: feedback_review_params }
        it_behaves_like 'returns 422 HTTP status'
      end

      context 'with invalid review id' do

        let(:feedback_review_params) {
          {
            review_id: 999,
            comment: "Very helpful!",
            rating: 5
          }
        }
        
        before { post "/api/v2/storefront/feedback_reviews", headers: headers, params: feedback_review_params }

        it_behaves_like 'returns 404 HTTP status'

      end


      context 'with missing review id' do
        let(:headers) { headers_bearer }

        let(:feedback_review_params) {
          {
            comment: "Very helpful!",
            rating: 5,
          }
        }
        
        before { post "/api/v2/storefront/feedback_reviews", headers: headers, params: feedback_review_params }

        it_behaves_like 'returns 422 HTTP status'

      end

    end

    context 'for guest user' do
      let(:headers) { {} }
      before { post "/api/v2/storefront/feedback_reviews", headers: headers, params: feedback_review_params }

      it_behaves_like 'returns 403 HTTP status'
    end

    context 'for guest user with anonymous reviews allowed' do
      let(:headers) { {} }
      
      before do
        Spree::Reviews::Config[:require_login] = false
        post "/api/v2/storefront/feedback_reviews", headers: headers, params: feedback_review_params
      end

      it_behaves_like 'returns 201 HTTP status'
    end
  end
end
