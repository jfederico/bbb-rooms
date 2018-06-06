Rails.application.routes.draw do
  scope ENV['RELATIVE_URL_ROOT'] || '' do
    resources :rooms
  end
end
