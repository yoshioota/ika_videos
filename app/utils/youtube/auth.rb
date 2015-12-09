require 'google/api_client'
require 'google/api_client/auth/storage'
require 'google/api_client/auth/storages/redis_store'

class Youtube::Auth
  attr_accessor :client, :youtube

  def get_authenticated_service
    raise 'http://localhost:3000/credential/edit にて認証情報を入力して下さい' unless credential = Credential.first

    @client = Google::APIClient.new(application_name: 'ika-videos', application_version: '1.0.0')
    @youtube = @client.discovered_api('youtube', 'v3')

    # TODO: Credentialに寄せたい。
    store = Google::APIClient::RedisStore.new(Redis.new)
    storage = Google::APIClient::Storage.new(store)
    storage.authorize
    if storage.authorization.nil?
      flow = Google::APIClient::InstalledAppFlow.new(
        client_id: credential.client_id,
        client_secret: credential.client_secret,
        scope: ['https://www.googleapis.com/auth/youtube']
      )
      @client.authorization = flow.authorize(storage)
    else
      @client.authorization = storage.authorization
    end

    [@client, @youtube]
  end
end
