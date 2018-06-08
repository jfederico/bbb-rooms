Rails.application.routes.draw do
  scope ENV['RELATIVE_URL_ROOT'] || '' do
    scope "rooms" do
      get "/launch", :to => "rooms#launch", as: :launch
      get ":id/meeting/join", :to => "rooms#meeting_join", as: :meeting_join
      get ":id/meeting/end", :to => "rooms#meeting_end", as: :meeting_end
      scope ":id/meetings" do
      end
    end
    resources :rooms
  end
end
