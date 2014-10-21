MultigroupEvents::Application.routes.draw do

  resources :password_resets
  resources :profiles 
#  resources :personal_profiles, except: [:show]
  resources :users do
    resources :verify_emails, only: [:new, :create], shallow: true
    resources :reset_verify_emails, only: [:new, :create], shallow: true
    resources :change_usernames, only: [:edit, :update], shallow: true
    resources :change_emails, only: [:edit, :update], shallow: true
    resources :change_avatars, only: [:edit, :update], shallow: true
  end

  post '/profiles/:id/enable_personal_on', to: "profiles#enable_personal_on",
  as: :enable_personal_profile_on
  resource :personal_profile, except: [:new, :create] do
    member do
      get 'edit_wants'
    end
  end
#  get 'personal_profile/edit', to: "PersonalProfile#edit", as: :edit_personal_profile
#  put 'personal_profile', to: "PersonalProfile#update", as: :personal_profile


  get '/users/:user_id/verify_email_token/:verify_token', 
       to: "verify_emails#create", as: 'verify_email_token'
 
  resources :sessions, only: [:new, :create, :destroy]

  root  'static_pages#home'
  match '/signup',  to: 'users#new', via: 'get'
  match '/signin',  to: 'sessions#new',         via: 'get'
  match '/signout', to: 'sessions#destroy',     via: 'delete'

  match '/home', to: 'static_pages#home', via: 'get'
  match '/help', to: 'static_pages#help', via: 'get'
  match '/about', to: 'static_pages#about', via: 'get'
  match '/contact', to: 'static_pages#contact', via: 'get'
  match '/error', to: 'static_pages#error', via: 'get'

#  match '~:username/edit/profile' => 'profiles#edit', :as => :edit_profile, via: 'get'
  match '~:id/personal' => 'personal_profiles#show', via: 'get', :as => :show_personal
#  match '~:username/edit_personal' => 'profiles#edit_personal', :as => :profile_edit_personal
#  match '~:username/edit_personal_looking' => 'profiles#edit_personal_looking', :as => :profile_edit_personal_looking_for
#  match '~:username/resume', :controller => 'profiles', :action => 'show', :section => 'resume', :as => :profile_resume
#  match '~:username/business' => 'profiles#show', :section => 'business', :as => :profile_business
#  match '~:username/photos' => 'profiles#show', :section => 'photos', :as => :profile_photos
#  match '~:username/events' => 'profiles#show', :section => 'events', :as => :profile_events
  match '~:id' => 'profiles#show', :as => :show_profile, via: 'get', :constraints => { :username => /[A-Za-z0-9_\.]+/ }

end
