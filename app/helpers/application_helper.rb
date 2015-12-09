module ApplicationHelper

  def controller_action_class_name
    "#{controller_name}__#{action_name}"
  end

  def exist_markers?(capture)
    capture.markers_count.nonzero?
  end

  def valid_videos?(capture)
    exist_videos?(capture)
  end

  def exist_videos?(capture)
    capture.videos_count.nonzero?
  end

  def time_fmt(time)
    return '' if time.blank?
    l time
  end

  def check_start_end(capture, column, options = {})
    if capture.send(:"#{column}_started_at").nil?
      '未作成'
    elsif capture.send(:"#{column}_started_at") && capture.send(:"#{column}_ended_at").nil?
      '作成中..'
    elsif capture.send(:"#{column}_started_at") && capture.send(:"#{column}_ended_at")
      if options[:finished] != :invisible
        '作成完了'
      end
    end
  end
end
