Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post "/posts", to: "posts#create"
      post "/ratings", to: "ratings#create"
    end
  end
end
