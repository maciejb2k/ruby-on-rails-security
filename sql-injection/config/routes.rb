Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get 'service-worker' => 'rails/pwa#service_worker', as: :pwa_service_worker
  get 'manifest' => 'rails/pwa#manifest', as: :pwa_manifest

  # Defines the root path route ("/")
  root 'injections#index'

  post 'reset_db', to: 'injections#reset_db', as: 'reset_db'

  # Dla każdej "metody" (akcja + widok) mamy:
  get  'injections/calculation'
  post 'injections/calculation'

  get  'injections/delete_by'
  post 'injections/delete_by'

  get  'injections/destroy_by'
  post 'injections/destroy_by'

  get  'injections/exists'
  post 'injections/exists'

  get  'injections/find_by'
  post 'injections/find_by'

  get  'injections/from'
  post 'injections/from'

  get  'injections/group'
  post 'injections/group'

  get  'injections/having'
  post 'injections/having'

  get  'injections/joins'
  post 'injections/joins'

  get  'injections/lock'
  post 'injections/lock'

  get  'injections/not'
  post 'injections/not'

  get  'injections/select'
  post 'injections/select'

  get  'injections/reselect'
  post 'injections/reselect'

  get  'injections/where'
  post 'injections/where'

  get  'injections/rewhere'
  post 'injections/rewhere'

  get  'injections/update_all'
  post 'injections/update_all'
end
