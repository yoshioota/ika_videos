class TimeUtil

  def self.duration_to_seconds(duration)
    hours, mins, secs, msec = split_duration(duration)
    seconds = hours * 3600 + mins * 60 + secs
    seconds += 1 if msec != 0
    seconds
  end

  def self.split_duration(duration)
    duration.split(/[:\.]/).map(&:to_i)
  end

  def self.total_frame_to_hmsf_str(total_frame)
    format_hmsf(* total_frame_to_hmsf(total_frame))
  end

  def self.total_frame_to_hmsf(total_frame)
    hour  = total_frame / (60 * 60 * 60)
    min   = total_frame % (60 * 60 * 60) / 3600
    sec   = total_frame % 3600 / 60
    frame = total_frame % 60
    [hour, min, sec, frame]
  end

  def self.total_seconds_to_str(total_seconds)
    format_sec(* total_seconds_to_hmsf(total_seconds))
  end

  def self.total_seconds_to_ms_str(total_seconds)
    format_ms(* total_seconds_to_ms(total_seconds))
  end

  def self.total_seconds_to_hmsf(total_seconds)
    hour  = total_seconds / 3600
    min   = total_seconds % 3600 / 60
    sec   = total_seconds % 60
    [hour, min, sec]
  end

  def self.total_seconds_to_ms(total_seconds)
    hour  = total_seconds / 3600
    min   = (hour * 60) + total_seconds % 3600 / 60
    sec   = total_seconds % 60
    [min, sec]
  end

  def self.format_ms(min, sec)
    "#{'%02d' % min}:#{'%02d' % sec}"
  end

  def self.format_sec(hour, min, sec)
    "#{'%02d' % hour}:#{'%02d' % min}:#{'%02d' % sec}"
  end

  def self.format_hmsf(hour, min, sec, frame)
    "#{'%02d' % hour}:#{'%02d' % min}:#{'%02d' % sec}.#{'%02d' % frame}"
  end

  def self.strptime(date, format)
    begin
      Time.strptime(date, format)
    rescue
      nil
    end
  end

  def self.param_date_to_date(param_date)
    return unless param_date
    Date.parse(param_date.values.join('-'))
  end

  def self.param_date_present?(param_date)
    return nil if param_date.nil?
    param_date.values.all?(&:present?)
  end
end
