Rails.application.routes.draw do
  get 'up' => 'rails/health#show', as: :rails_health_check
  get 'service-worker' => 'rails/pwa#service_worker', as: :pwa_service_worker
  get 'manifest' => 'rails/pwa#manifest', as: :pwa_manifest

  get 'reports', to: 'reports#index'
  get 'reports/unsafe_download', to: 'reports#unsafe_download'
  get 'reports/safe_download', to: 'reports#safe_download'

  root to: 'reports#index'
end
