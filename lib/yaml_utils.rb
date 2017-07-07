require 'pry-byebug'

class YamlUtils
  DATA_PATH = 'data/data.yml'.freeze
  STATS_PATH = 'statistics/stats.yml'.freeze

  def self.save_sessions(sessions)
    Dir.mkdir 'data' unless File.exist? 'data'
    File.open(DATA_PATH, 'w') { |file| file.write YAML.dump(sessions) }
  rescue => exception
    return Rack::Response.new("Can't save to #{DATA_PATH}. #{exception}", 404)
  end

  def self.read_sessions
    begin
      sessions = YAML.load_file(DATA_PATH)
    rescue => exception
      puts "Can't open a file. #{exception}"
    end
    sessions
  end

  def self.save_result(sid, game, name)
    binding.pry
    Dir.mkdir 'statistics' unless File.exist? 'statistics'
    game_result = read_stats
    game_result[sid] = { name: name, time: Time.now, score: game.score, attempts: game.guess_count }
    File.open(STATS_PATH, 'w') { |file| file.write YAML.dump(game_result) }
  rescue => exception
    return Rack::Response.new("Can't save to #{DATA_PATH}. #{exception}", 404)
  end

  def self.read_stats
    begin
      stats = YAML.load_file(STATS_PATH)
      binding.pry
    rescue => exception
      puts "Can't open a file. #{exception}"
    end
    return {} unless stats
    # Change key of hash to be unique (probably time, but not a session)
    stats#.sort_by { |item| item[:score] }
  end
end
