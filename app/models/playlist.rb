# == Schema Information
#
# Table name: playlists
#
#  id                     :integer          not null, primary key
#  youtube_id             :string(255)
#  title                  :string(255)
#  date_on                :date
#  playlists_videos_count :integer          default(0)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class Playlist < ActiveRecord::Base
  has_many :playlists_videos
  has_many :videos, through: :playlists_videos

  def youtube_url
    v = playlists_videos.joins(:video).where('videos.youtube_id IS NOT NULL').order('videos.file_name').first.try(:video).try(:youtube_id)
    v ? "https://www.youtube.com/watch?v=#{v}&list=#{youtube_id}" : nil
  end
end
