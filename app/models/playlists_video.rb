class PlaylistsVideo < ActiveRecord::Base
  belongs_to :playlist, counter_cache: true
  belongs_to :video
end
