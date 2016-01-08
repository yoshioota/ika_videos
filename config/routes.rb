Rails.application.routes.draw do

  root to: redirect('/captures')

  resources :captures, only: %w(index destroy) do
    member do
      post :execute_all
      post :calculate_total_frames
      post :open_capture
      post :open_videos
    end
    collection do
      get :captures
      delete :bulk_destroy
    end

    resources :frames, only: %w(index show) do
      collection do
        get :search
        post :create_files
      end
      member do
        get :img
      end
    end

    resources :markers, only: %w(index) do
      collection do
        post :create_markers
        post :create_games
      end
    end
  end

  resources :playlists, only: %w(index show) do
    collection do
      get :playlist_items
    end
    member do
      post :open_videos
      post :upload_youtube
      post :add_playlist_youtube
      post :reveal_in_finder
      post :reorder
      post :delete_movie_files
    end
  end

  resources :videos, only: %w(index destroy) do
    member do
      post :open
      post :upload_youtube
    end
  end

  resources :game_results

  resource :credential, only: %w(edit update)

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
