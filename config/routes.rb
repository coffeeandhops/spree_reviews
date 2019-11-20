Spree::Core::Engine.add_routes do
  namespace :admin do
    resources :reviews, only: [:index, :destroy, :edit, :update] do
      member do
        get :approve
      end
      resources :feedback_reviews, only: [:index, :destroy]
    end
    resource :review_settings, only: [:edit, :update]
  end

  resources :products, only: [] do
    resources :reviews, only: [:index, :new, :create] do
    end
  end
  post '/reviews/:review_id/feedback(.:format)' => 'feedback_reviews#create', as: :feedback_reviews

  namespace :api, defaults: { format: 'json' } do
    namespace :v2 do

      namespace :storefront do
        # resources :products, only: [] do
        #   resources :reviews, only: [:index, :new, :create] do
        #   end
        # end
        resources :reviews, only: [:show, :index, :create]
        resources :feedback_reviews, only: [:create]
      end
    end
  end
end
