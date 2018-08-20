Rails.application.routes.draw do
  # Endpoint for Cloudwatch to check API is up and running
  get '/check', to: 'check#index', defaults: { format: :json }

  namespace :v1, defaults: { format: :json } do
    resources :frameworks, only: %i[index show]
    resources :suppliers, only: %i[index]
    resources :memberships, only: %i[index create destroy]
    resources :agreements, only: %i[create]
    resources :submissions, only: %i[show create update] do
      member do
        post 'calculate', to: 'submissions#calculate'
        post 'complete', to: 'submissions#complete'
      end

      resources :files, only: %i[create update show], controller: 'submission_files'
      resources :entries, only: %i[create], controller: 'submission_entries'
    end
    resources :tasks, only: %i[index show create update] do
      member do
        post :complete
        post :no_business
      end
    end

    resources :files, only: [] do
      resources :entries, only: %i[show create update], controller: 'submission_entries'
      resources :blobs, only: :create, controller: 'submission_file_blobs'
    end

    namespace :events do
      post 'user_signed_in'
      post 'user_signed_out'
    end
  end
end
