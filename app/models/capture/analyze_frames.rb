class Capture::AnalyzeFrames

  def initialize(capture: nil, verbose: false)
    @capture = capture
    @verbose = verbose
  end

  def analyze_by_total_frame(total_frame)
    file_path = @capture.get_frame_image_file_path_total_frame(total_frame)
    fail file_path.to_s unless File.file?(file_path)

    puts "ID[#{@capture.id}] #{'%02.02f' % (total_frame.fdiv(@capture.total_frames) * 100)}% #{total_frame}/#{@capture.total_frames}" if @verbose

    ret = analyze(file_path)

    if prms = ret[:black]
      puts 'black!' if @verbose
      @capture.markers.find_or_create_by \
          marker_type: 'black',
          total_frame: total_frame,
          min_score: prms[:min_score],
          max_score: prms[:max_score]
    end

    if prms = ret[:white]
      puts 'white!' if @verbose
      @capture.markers.find_or_create_by \
          marker_type: 'white',
          total_frame: total_frame,
          min_score: prms[:min_score],
          max_score: prms[:max_score]
    end

    if prms = ret[:finish]
      puts 'finish!' if @verbose
      @capture.markers.find_or_create_by \
        marker_type: 'finish',
        total_frame: total_frame,
        min_score: prms[:min_score],
        max_score: prms[:max_score]
    end
  end

  def analyze(image_file_path)
    start = Time.now
    ret = Splatoon::AnalyzeFrame.new(image_file_path).analyze
    puts "#{'%.2f' % ((Time.now - start).to_f * 1000)} ms" if @verbose
    ret
  end
end
