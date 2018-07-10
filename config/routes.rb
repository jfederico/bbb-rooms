Rails.application.routes.draw do
  scope ENV['RELATIVE_URL_ROOT'] || '' do
    resources :rooms
    scope 'rooms/:id/meetings' do
      post '/join', :to => 'rooms#meeting_join', as: :meeting_join
      post '/end', :to => 'rooms#meeting_end', as: :meeting_end
    end
    scope 'rooms/:id/recordings' do
    end
    get '/launch', :to => 'rooms#launch', as: :launch
    get '/sessions/create'
    get '/sessions/failure'
    get '/auth/:provider/callback', to: 'sessions#create', as: :omniauth_callback
    get '/auth/failure', to: 'sessions#failure', as: :omniauth_failure
    get '/errors/:code', to: 'errors#index', as: :errors
  end
end
