class Capture::AnalyzeFrames
  def initialize(capture: nil, verbose: false)
    @capture = capture
    @verbose = verbose
  end

  def analyze_by_total_frame(total_frame)
    file_path = @capture.get_frame_image_file_path_total_frame(total_frame)
    fail file_path.to_s unless File.file?(file_path)

    puts "ID[#{@capture.id}] #{'%02.02f' % (total_frame.fdiv(@capture.total_frames) * 100)}% #{total_frame}/#{@capture.total_frames}" if @verbose

    start = Time.now
    af = Splatoon::AnalyzeFrame.new(file_path)
    ret = af.analyze

    if prms = ret[:black]
      puts 'black!' if @verbose
      find_or_create_makrers(@capture, 'black', total_frame, prms)
    elsif prms = ret[:white]
      puts 'white!' if @verbose
      find_or_create_makrers(@capture, 'white', total_frame, prms)
    elsif prms = ret[:finish]
      puts 'finish!' if @verbose
      find_or_create_makrers(@capture, 'finish', total_frame, prms)
    end

    # elsif prms = af.stage
    #   find_or_create_makrers(@capture, prms[:stage_name], total_frame, prms)
    # elsif prms = af.game_result
    #   find_or_create_makrers(@capture, prms[:game_result_name], total_frame, prms)
    # end

    puts "#{'%.2f' % ((Time.now - start).to_f * 1000)} ms" if @verbose
  end

  def find_or_create_makrers(capture, marker_type, total_frame, prms)
    options = {
      marker_type: marker_type,
      total_frame: total_frame,
      min_score: prms[:min_score],
      max_score: prms[:max_score]
    }
    capture.markers.find_or_create_by(options)
  end
end
