require 'erb'
require 'codebreaker_artem/game'
require 'yaml'
require './lib/utils'

require 'pry'

class RackApp
  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @sessions = Utils.read_sessions || {}
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
        game2 = CodebreakerArtem::Game.new
        game3 = CodebreakerArtem::Game.new
        game2.start
        @request.session['init'] = true
        sid = @request.session['session_id']

        save_game(2, game2)
        save_game(3, game3)
                save_game(sid, game)
        save_game(4, game)
        Utils.save_sessions @sessions
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
    # game = Utils.load_game
    # game.secret_code || 'No game yet'
  end

  private

  def save_game(sid, game)
    @sessions[sid] = game
  end
end
