# == Schema Information
#
# Table name: playlists_videos
#
#  id          :integer          not null, primary key
#  youtube_id  :string(255)
#  playlist_id :integer          not null
#  video_id    :integer          not null
#  order_no    :integer          default(9999)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class PlaylistsVideo < ActiveRecord::Base
  belongs_to :playlist, counter_cache: true
  belongs_to :video
end
