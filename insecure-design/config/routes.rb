Rails.application.routes.draw do
  get 'up' => 'rails/health#show', as: :rails_health_check
  get 'service-worker' => 'rails/pwa#service_worker', as: :pwa_service_worker
  get 'manifest' => 'rails/pwa#manifest', as: :pwa_manifest

  # Insecure Design
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  get 'dashboard', to: 'dashboard#index'
  get 'phishing-login', to: 'phishing#fake_login'
  post 'phishing-steal', to: 'phishing#steal_credentials'

  # Rate limiting
  get 'rate_limited', to: 'errors#rate_limited'

  root 'sessions#new'
end
