# require 'erb'
require 'codebreaker_artem/game'
require 'yaml'
require './lib/utils'

require 'pry-byebug'

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
    when '/update_word' then update_word
    when '/start' then start
    when '/submit_guess' then submit_guess
    else Rack::Response.new('Not found', 404)
    end
  end

  def word
    @request.cookies['word'] || 'Nothing'
  end

  def game
    sid = @request.session['session_id']
    game = @sessions[sid]
    game.inspect.tr('#<>::@', '') || 'No game yet'
  end

  private

  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def update_word
    Rack::Response.new do |response|
      response.set_cookie('word', @request.params['word'])
      response.redirect('/')
    end
  end

  def start
    Rack::Response.new do |response|
      game = CodebreakerArtem::Game.new
      game.start
      @request.session['init'] = true
      sid = @request.session['session_id']
      save_game(sid, game)
      Utils.save_sessions @sessions
      response.redirect('/')
    end
  end

  def submit_guess
    Rack::Response.new { |response| response.redirect('/') }
  end

  def save_game(sid, game)
    @sessions[sid] = game
  end
end
