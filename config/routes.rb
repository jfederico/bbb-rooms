Rails.application.routes.draw do
  resources :rooms

  scope ENV['RELATIVE_URL_ROOT'] || '/' do
  end
end
