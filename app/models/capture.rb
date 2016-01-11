# == Schema Information
#
# Table name: captures
#
#  id                              :integer          not null, primary key
#  title                           :string(255)
#  total_frames                    :integer
#  duration                        :string(255)
#  full_path                       :string(255)
#  exist                           :boolean
#  started_at                      :datetime
#  ended_at                        :datetime
#  compute_total_frames_started_at :datetime
#  compute_total_frames_ended_at   :datetime
#  create_thumbnails_started_at    :datetime
#  create_thumbnails_ended_at      :datetime
#  create_markers_started_at       :datetime
#  create_markers_ended_at         :datetime
#  analyze_videos_started_at       :datetime
#  analyze_videos_ended_at         :datetime
#  markers_count                   :integer          default(0)
#  videos_count                    :integer          default(0)
#  visible                         :boolean          default(TRUE)
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#

class Capture < ActiveRecord::Base
  has_many :markers, dependent: :destroy
  has_many :videos, dependent: :nullify

  scope :visible, -> { where(visible: true) }

  def self.make_image_file_name(file_no)
    "img-#{'%015d' % file_no}.jpeg"
  end

  def self.update_hash
    # Memo: この式ではローカルビデオファイルの更新が検知できない。
    # 検知させるか、もしくは10分に1回は更新させるようにするか。。
    "#{last_updated_at_i}:#{self.count}:#{self.last.try(:id)}"
  end

  def self.last_updated_at_i
    (self.order(updated_at: :desc).limit(1).pluck(:updated_at).first || 0).to_i
  end

  def file_size
    File.size(full_path) if File.exist?(full_path)
  end

  def captured_dir
    File.dirname(full_path)
  end

  def get_or_create_frame_image_file_path_total_frame(total_frame, scale = Settings.default_scale)
    fail total_frame.to_s if total_frame >= self.total_frames
    path = get_frame_image_file_path_total_frame(total_frame, scale)
    return path if File.file?(path)
    CreateFrameFilesWorker.new(self).make_frame(total_frame, scale)
  end

  def get_frame_image_file_path_total_frame(total_frame, scale = Settings.default_scale)
    hour, min, sec, frame = TimeUtil.total_frame_to_hmsf(total_frame)
    get_frame_image_file_path(hour, min, sec, frame, scale)
  end

  def get_frame_image_file_path(hour, min, sec, frame, scale)
    file_no = (sec * 60) + frame + 1
    file_name = make_image_file_name(file_no)
    dir = get_frames_dir(scale)
    File.join(dir, (hour * 60 + min).to_s, file_name)
  end

  def get_frames_dir(scale = nil)
    scale ?
        File.join(Settings.game_frames_path, self.id.to_s, scale.to_s) :
        File.join(Settings.game_frames_path, self.id.to_s)
  end

  def make_image_file_name(file_no)
    self.class.make_image_file_name(file_no)
  end

  def total_min
    min, mod = total_frames.divmod(3600)
    mod.zero? ? min : min + 1
  end

  def total_seconds
    seconds, mod = total_frames.divmod(60)
    mod.zero? ? seconds : seconds + 1
  end

  def start_end(column)
    self.reload.update!("#{column}_started_at": Time.now, "#{column}_ended_at": nil)

    yield

    # FIXME: PostgreSQLではここで死ぬ。
    # 以下の情報を見てやってみてもダメ。
    # http://attracie.hatenablog.com/entry/2015/10/18/200407
    self.reload.update!("#{column}_ended_at": Time.now)
  end
end
