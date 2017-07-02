class YamlUtils
  DATA_PATH = 'data/data.yml'.freeze

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
end
