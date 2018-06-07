Rails.application.routes.draw do
  scope ENV['RELATIVE_URL_ROOT'] || '' do
    get "/rooms/launch", :to => "rooms#launch", as: :launch
    resources :rooms
  end
end
