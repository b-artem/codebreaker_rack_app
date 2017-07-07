# frozen_string_literal: true

class YamlUtils
  DATA_PATH = 'data/sessions.yml'
  STATS_PATH = 'data/statistics.yml'

  def self.save_sessions(sessions)
    save_data(DATA_PATH) do
      File.open(DATA_PATH, 'w') { |file| file.write YAML.dump(sessions) }
    end
  end

  def self.save_result(game, name)
    save_data(STATS_PATH) do
      game_result = read_stats
      game_result[Time.now] = { name: name, score: game.score,
                                attempts: game.guess_count }
      File.open(STATS_PATH, 'w') { |file| file.write YAML.dump(game_result) }
    end
  end

  def self.read_sessions
    read_data(DATA_PATH) { |sessions| sessions }
  end

  def self.read_stats
    read_data(STATS_PATH) do |results|
      return {} unless results
      results.to_h.sort_by { |key, _| key }.reverse.to_h
    end
  end

  def self.save_data(path)
    Dir.mkdir 'data' unless File.exist? 'data'
    yield if block_given?
  rescue => exception
    puts "Can't save to #{path}. #{exception}"
  end

  def self.read_data(path)
    begin
      data = YAML.load_file(path)
    rescue => exception
      puts "Can't open a file. #{exception}"
    end
    yield data if block_given?
  end
end
