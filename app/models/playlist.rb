class Playlist < ActiveRecord::Base
  has_many :playlists_videos
  has_many :videos, through: :playlists_videos

  def youtube_url
    v = playlists_videos.joins(:video).where('videos.youtube_id IS NOT NULL').order('videos.file_name').first.try(:video).try(:youtube_id)
    v ? "https://www.youtube.com/watch?v=#{v}&list=#{youtube_id}" : nil
  end
end
