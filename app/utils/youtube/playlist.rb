require 'google/api_client'

class Youtube::Playlist
  def insert(title: '', description: '', privacy_status: 'public')
    body = {
      snippet: {
        title: title,
        description: description
      },
      status: {
        privacyStatus: privacy_status
      }
    }

    begin
      client, youtube = Youtube::Auth.new.get_authenticated_service

      response = client.execute!(
        api_method: youtube.playlists.insert,
        body_object: body,
        parameters: {
          part: body.keys.join(',')
        }
      )
      puts "Playlist id '#{response.data.id}' was successfully uploaded."
      response.data.id
    rescue Google::APIClient::TransmissionError => e
      puts e.result.body
      raise
    end
  end

  def list(parameters = nil)
    # TODO: 50件以上取得する
    parameters ||= {
        mine: true,
        part: 'snippet',
        maxResults: 50
    }

    client, youtube = Youtube::Auth.new.get_authenticated_service
    client.execute!(
      api_method: youtube.playlists.list,
      parameters: parameters
    )
  end
end
