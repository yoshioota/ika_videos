require 'google/api_client'

class Youtube::PlaylistItems
  def bulk_insert(playlist)
    playlist
        .playlists_videos
        .joins(:video)
        .where('playlists_videos.youtube_id IS NULL')
        .where('videos.youtube_id IS NOT NULL')
        .order(:order_no)
        .each do |playlists_video|
      insert(playlist, playlists_video)
    end
  end

  def insert(playlist, playlists_video)
    video = playlists_video.video
    client, youtube = Youtube::Auth.new.get_authenticated_service
    response = client.execute!(
        api_method: youtube.playlist_items.insert,
        parameters: {
            part: 'snippet',
        },
        body_object: {
            playlistId: playlist.youtube_id,
            snippet: {
                playlistId: playlist.youtube_id,
                resourceId: {
                    kind: 'youtube#video',
                    videoId: video.youtube_id
                }
            }
        },
    )
    playlists_video.update!(youtube_id: response.data['id'])
  end
end
