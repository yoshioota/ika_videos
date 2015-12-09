# youtubeでのuploadで必要.
# 設定しないとErrno::EPIPE: Broken pipe になる。
Faraday.default_adapter = :excon
