class PlaylistsController < ApplicationController
  before_action :set_playlist, only: %w[show open_videos
        upload_youtube add_playlist_youtube reorder delete_movie_files]

  def index
    @playlists = Playlist.order(date_on: :desc).all
  end

  def show
    @capture_ids = @playlist.videos.includes(:capture).pluck(:capture_id).uniq.compact
    search_playlist_items
    if request.xhr?
      render action: 'playlist_items', format: :js
    end
  end

  def playlist_items
    search_playlist_items
  end

  def add_playlist_youtube
    Youtube::PlaylistItems.new.bulk_insert(@playlist)
    head :ok
  end

  def new
    @playlist = Playlist.new
  end

  def reorder
    PlaylistsVideos::Reorder.new(@playlist).perform
    head :ok
  end

  def open_videos
    paths = @playlist.videos.map(&:output_file_path).select { |s| File.file?(s) }
    CommandUtil.open_paths(*paths)
    head :ok
  end

  def upload_youtube
    @playlist.videos.order(started_at: :asc).each do |video|
      next if video.youtube_id
      UploadVideoWorker.perform_async(video.id)
    end
    head :ok
  end

  def reveal_in_finder
    CommandUtil.open_paths(Settings.output_path)
    head :ok
  end

  def delete_movie_files
    @playlist.videos.each do |video|
      FileUtils.rm_f video.output_file_path
    end
    head :ok
  end

  private

  def search_playlist_items
    check_reorder
    @show_img = (params[:show_img].presence || 0).to_i
    @playlists_videos = @playlist.playlists_videos.includes(video: :capture).order(:order_no)
  end

  def check_reorder
    PlaylistsVideo::Reorder.new(@playlist).perform if @playlist.playlists_videos.none?
  end

  def set_playlist
    @playlist = Playlist.includes(:playlists_videos).find(params[:id])
  end
end
