class FfmpegUtil

  def self.get_metadata(_path)
    path = Shellwords.escape(_path)
    cmd = "ffprobe -i #{path} -hide_banner"
    ret = CommandUtil.command_execute(cmd)
    metadata = {}
    ret.split(/\n/).each do |line|
      line = line.strip
      case line
      when /Duration: ([\d:\.]+), start: ([\d\.]+), bitrate: (.+)$/
        metadata[:duration] = $1
        hours, mins, secs, msecs = TimeUtil.split_duration(metadata[:duration])
        metadata[:duration_hours] = hours
        metadata[:duration_mins]  = mins
        metadata[:duration_secs]  = secs
        metadata[:duration_msecs] = msecs

        metadata[:duration_seconds] = TimeUtil.duration_to_seconds($1)
        metadata[:start] = $2
        metadata[:bitrate] = $3
      when /creation_time\s+: (.+)$/
        metadata[:creation_time] ||= Time.parse($1 + ' UTC')
      end
    end
    fail if metadata.blank?
    metadata
  end

  def self.initialize_frame_dir(output_path)
    fail unless output_path.index Settings.game_frames_path
    FileUtils.rm_rf(output_path) if File.exist?(output_path)
    FileUtils.mkdir_p(output_path)
  end

  def self.make_frames(seek, input_file_path, output_path, vframes = 3600, scale = 1)
    x = 1280 / scale
    y = 720 / scale
    scale_str   = "-vf scale=#{x}:#{y}" if scale != 1
    vframes_str = "-vframes #{vframes}"
    quality_str = '-q:v 1'
    input_file_path = Shellwords.escape(input_file_path)
    output_path = Shellwords.escape(output_path)
    cmd = "ffmpeg -ss #{seek} -i #{input_file_path} -f image2 #{vframes_str} #{quality_str} #{scale_str} #{output_path} -hide_banner"
    CommandUtil.command_execute(cmd)
  end

  def self.extract_movie(start_frame:, end_frame:, input_file:, output_file:)
    FileUtils.mkdir_p(File.dirname(output_file))
    start_time = TimeUtil.total_frame_to_str(start_frame)
    length = TimeUtil.total_frame_to_str(end_frame - start_frame)
    input_file = Shellwords.escape(input_file)
    output_file = Shellwords.escape(output_file)
    cmd = "ffmpeg -ss #{start_time} -i #{input_file} -t #{length} -vcodec copy -acodec copy #{output_file} -hide_banner"
    CommandUtil.command_execute(cmd)
  end

  # FIXME: 正確な動画のフレーム数の取得を高速化する。。
  # 現在分の単位から**:**:00から取得している。そうしないと数フレ画像と誤差が出る。。
  def self.get_total_frames(path)
    fail unless metadata = get_metadata(path)
    hours, min, sec, frame = TimeUtil.split_duration(metadata[:duration])
    total_frames = hours * 216000 + min * 3600
    return total_frames if sec.zero? && frame.zero?

    Dir.mktmpdir do |dir|
      make_frames('%02d:%02d:%02d.00' % [hours, min, 0], path, File.join(dir, 'img-%05d.jpeg'), 3600, 64)
      total_frames + Dir[File.join(dir, '**.jpeg')].size
    end
  end
end
