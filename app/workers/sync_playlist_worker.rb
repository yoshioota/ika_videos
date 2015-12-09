class SyncPlaylistWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { hourly }

  def perform
    Youtube::Sync::Playlist.new.sync
  end
end
