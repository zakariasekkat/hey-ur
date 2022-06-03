# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'urls#index'

  resources :urls, only: %i[index create show], param: :url
  get :json_file , to: 'urls#json_file'
  get ':short_url', to: 'urls#visit', as: :visit
end
