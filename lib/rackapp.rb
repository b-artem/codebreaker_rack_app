require 'erb'
require 'codebreaker_artem/game'
require 'pry'
require 'yaml'

class RackApp
  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
  end

  def response
    case @request.path
    when '/' then Rack::Response.new(render('index.html.erb'))
    when '/update_word'
      Rack::Response.new do |response|
        response.set_cookie('word', @request.params['word'])
        response.redirect('/')
      end
    when '/start'
      Rack::Response.new do |response|
        game = CodebreakerArtem::Game.new
        game.start
        file = 'data/' + Time.now.to_f.to_s.delete('.') + '.yml'
        begin
          File.open(file, 'w') { |f| f.write(YAML.dump(game)) }
          response.set_cookie('file', file)
        rescue => exception
          return Rack::Response.new("Couldn't save to #{file}. #{exception}", 404)
        end
        response.redirect('/')
      end
    else Rack::Response.new('Not found', 404)
    end
  end

  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def word
    @request.cookies['word'] || 'Nothing'
  end

  def game
    begin
      game = YAML.load_file(@request.cookies['file'])
    rescue
      return "Couldn't open a file"
    end
    game.secret_code || 'No game yet'
  end
end
