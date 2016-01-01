class Settings < Settingslogic
  source "#{Rails.root}/config/settingslogic.yml"
  namespace Rails.env

  # MEMO: application.yml内で参照するとstack level too deep errorになるのでこちらへ移動...

  def self.game_frames_path
    File.join(Settings.output_path, 'frames')
  end

  def self.movie_output_path
    File.join(Settings.output_path, 'movies')
  end
end
