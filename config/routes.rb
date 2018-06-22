Rails.application.routes.draw do
  scope ENV['RELATIVE_URL_ROOT'] || '' do
    scope "rooms" do
      get "/launch", :to => "rooms#launch", as: :launch
      post ":id/meeting/join", :to => "rooms#meeting_join", as: :meeting_join
      post ":id/meeting/end", :to => "rooms#meeting_end", as: :meeting_end
      scope ":id/meetings" do
      end
      scope ":id/recordings" do
      end
    end
    resources :rooms
  end
end
