class CommandUtil

  def self.open_paths(*paths)
    `open #{paths.map{|path| Shellwords.escape(path)}.join(' ')}`
  end

  def self.command_execute(cmd)
    #http://ikm.hatenablog.jp/entry/2014/11/12/003925
    ret = ''

    Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
      stdin.close_write # 標準入力を閉じる。

      begin
        # 標準出力、標準エラーの出力があるまで延々と待ち、随時1行ずつ書き出す
        loop do
          IO.select([stdout, stderr]).flatten.compact.each do |io|
            io.each do |line|
              next if line.nil? || line.empty?
              ret << line
              # puts line
            end
          end
          # 標準出力、標準エラーでEOFが検知された、つまり外部コマンドの実行が終了したらループを抜ける
          break if stdout.eof? && stderr.eof?
        end
      rescue EOFError
      end
    end
    ret
  end
end
