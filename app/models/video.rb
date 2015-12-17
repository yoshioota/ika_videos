class Video < ActiveRecord::Base

  belongs_to :capture, counter_cache: true
  has_many :playlists_videos, dependent: :destroy

  def output_file_path
    File.join Settings.movie_output_path, file_name
  end

  def total_seconds
    seconds, mod = total_frames.divmod(60)
    mod.zero? ? seconds : seconds + 1
  end

  # TODO: upload_statusを作りアップロード中かの判別をする。
  def uploadable?
    exist_local? && !youtube_id?
  end

  def exist_local?
    File.exist?(output_file_path)
  end

  def title
    [File.basename(output_file_path, '.*'), game_rule, game_stage, game_result].join('-')
  end
end
