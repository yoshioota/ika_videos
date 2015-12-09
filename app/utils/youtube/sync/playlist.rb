class Youtube::Sync::Playlist
  def sync
    create_dates_if_not_exist
    pull
  end

  # TODO: 現在必ず作成するようになっている。Videoが無いときには作成しないようにする
  def create_dates_if_not_exist
    today = Date.today
    youtube_date_map = get_youtube_dates_map
    ((today - Settings.create_youtube_playlist_dates)..today).each do |date|
      Youtube::Playlist.new.insert(title: date.strftime('%Y-%m%d')) unless youtube_date_map.key?(date)
    end
  end

  def pull
    Youtube::Playlist.new.list.data.items.each do |playlist_params|
      playlist = Playlist.where(youtube_id: playlist_params['id']).first_or_initialize
      playlist.title = playlist_params['snippet']['title']
      playlist.date_on = TimeUtil.strptime(playlist_params['snippet']['title'], '%Y-%m%d').to_date
      playlist.save!
    end
  end

  private

  def get_youtube_dates_map
    ret = {}
    Youtube::Playlist.new.list.data.items.each do |playlist_parameters|
      next unless time = TimeUtil.strptime(playlist_parameters['snippet']['title'], '%Y-%m%d')
      ret[time.to_date] = playlist_parameters
    end
    ret
  end
end
