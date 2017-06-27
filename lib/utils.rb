class Utils
  DATA_PATH = 'data/data.yml'.freeze

  # def self.save_game(sid, game)
  #   Dir.mkdir 'data' unless File.exist? 'data'
  #   File.open(DATA_PATH, 'a') { |f| f.write YAML.dump(sid => game) }
  # rescue => exception
  #   return Rack::Response.new("Couldn't save to #{DATA_PATH}. #{exception}", 404)
  # end

  def self.load_game
    # begin
    #   game = YAML.load_file(DATA_PATH)
    # rescue => exception
    #   return "Couldn't open a file. #{exception}"
    # end
    # game
  end

  def self.save_sessions(sessions)
    Dir.mkdir 'data' unless File.exist? 'data'
    File.open(DATA_PATH, 'w') { |f| f.write YAML.dump(sessions) }
  rescue => exception
    return Rack::Response.new("Couldn't save to #{DATA_PATH}. #{exception}", 404)
  end


  def self.read_sessions
    begin
      sessions = YAML.load_file(DATA_PATH)
    rescue => exception
      puts "Couldn't open a file. #{exception}"
    end
    sessions
  end
end
