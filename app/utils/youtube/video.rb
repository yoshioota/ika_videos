require 'google/api_client'

class Youtube::Video

  GAME_CATEGORY_ID = 20

  def insert_by_video(video)
    return if video.youtube_id
    fail unless File.file?(video.output_file_path)
    opts = {
        file: video.output_file_path,
        description: create_description(video),
        title: video.title
    }
    video.youtube_id = insert(opts)
    video.save!
  end

  def insert(file:, title: '', description: '', keywords: '', category_id: GAME_CATEGORY_ID, privacy_status: 'public')
    body = {
      snippet: {
        title: title,
        description: description,
        tags: keywords.to_s.split(','),
        categoryId: category_id
      },
      status: {
        privacyStatus: privacy_status
      }
    }

    begin
      start = Time.now
      puts "Send start [#{start}]"
      client, youtube = Youtube::Auth.new.get_authenticated_service

      response = client.execute!(
        api_method: youtube.videos.insert,
        body_object: body,
        media: Google::APIClient::UploadIO.new(file, 'video/*'),
        parameters: {
          uploadType: 'resumable',
          part: body.keys.join(',')
        }
      )
      response.resumable_upload.send_all(client)
      puts "Video id '#{response.data.id}' was successfully uploaded. [#{'%.2f' % (Time.now - start).to_f} sec]"
      response.data.id
    rescue Google::APIClient::TransmissionError => e
      puts e.result.body
      raise
    end
  end

  def create_description(video)
    ret = ''
    ret << "rule: #{video.game_rule}\n" if video.game_rule
    ret << "stage: #{video.game_stage}\n" if video.game_stage
    ret << "result: #{video.game_result}\n" if video.game_result
    ret
  end
end
