require 'pry-byebug'

class YamlUtils
  DATA_PATH = 'data/data.yml'.freeze
  STATS_PATH = 'data/stats.yml'.freeze

  def self.save_sessions(sessions)
    Dir.mkdir 'data' unless File.exist? 'data'
    File.open(DATA_PATH, 'w') { |file| file.write YAML.dump(sessions) }
  rescue => exception
    puts "Can't save to #{DATA_PATH}. #{exception}"
  end

  def self.read_sessions
    begin
      sessions = YAML.load_file(DATA_PATH)
    rescue => exception
      puts "Can't open a file. #{exception}"
    end
    sessions
  end

  def self.save_result(game, name)
    Dir.mkdir 'data' unless File.exist? 'data'
    game_result = read_stats
    game_result[Time.now] = { name: name, score: game.score, attempts: game.guess_count }
    File.open(STATS_PATH, 'w') { |file| file.write YAML.dump(game_result) }
  rescue => exception
    puts "Can't save to #{DATA_PATH}. #{exception}"
  end

  def self.read_stats
    begin
      stats = YAML.load_file(STATS_PATH)
    rescue => exception
      puts "Can't open a file. #{exception}"
    end
    return {} unless stats
    stats.to_h.sort_by { |key, result| result[:score] }.reverse.to_h
  end
end
