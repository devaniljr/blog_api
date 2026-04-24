Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      get "/posts/top", to: "posts#top"
      post "/posts", to: "posts#create"
      post "/ratings", to: "ratings#create"
      get "/ips", to: "ips#index"
    end
  end
end
