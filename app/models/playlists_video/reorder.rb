class PlaylistsVideo::Reorder

  def initialize(playlist)
    @playlist = playlist
  end

  def perform
    Video.where(started_at: @playlist.date_on.to_time.all_day).all.each do |video|
      @playlist.videos << video unless @playlist.playlists_videos.to_a.any?{|ps| ps.video_id == video.id}
    end

    @playlist
        .reload
        .playlists_videos
        .includes(:video)
        .order('videos.started_at')
        .each
        .with_index(1) do |ps, idx|
      ps.update!(order_no: idx) if ps.order_no != idx
    end
  end
end
