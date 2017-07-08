require 'codebreaker_artem/game'
require 'codebreaker_artem/validator'
require 'yaml'
require './lib/yaml_utils'
require './lib/helpers'

MAX_ATTEMPTS = CodebreakerArtem::Game::MAX_GUESS_NUMBER

class RackApp
  include Helpers

  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @sessions = YamlUtils.read_sessions || {}
    find_game
  end

  def response
    case @request.path
    when '/' then home
    when '/start' then start
    when '/submit_guess' then submit_guess
    when '/hint' then hint
    when '/save_result' then save_result
    when '/cancel_save_result' then cancel_save_result
    when '/statistics' then statistics
    else Rack::Response.new('Not found', 404)
    end
  end

  private

  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def home
    return Rack::Response.new(render('index.html.erb')) if @game
    start
  end

  def find_game
    sid = @request.session['session_id']
    return unless @sessions[sid]
    @game = @sessions[sid][:game]
    @guess_log = @sessions[sid][:guess_log]
    @won = @sessions[sid][:won]
    @lost = @sessions[sid][:lost]
  end

  def save_game(sid, game, guess_log)
    @sessions[sid] = { game: game, guess_log: guess_log }
  end

  def start
    Rack::Response.new do |response|
      game = CodebreakerArtem::Game.new
      game.start
      @request.session['init'] = true
      response.set_cookie('secret_number', '')
      response.set_cookie('secret_position', '')
      response.set_cookie('name', '')
      response.set_cookie('save_result', '')
      guess_log = ''
      save_game(@request.session['session_id'], game, guess_log)
      YamlUtils.save_sessions @sessions
      response.redirect('/')
    end
  end

  def submit_guess
    return Rack::Response.new { |response| response.redirect('/') } if won? || lost?
    Rack::Response.new do |response|
      guess = @request.params['guess']
      if Validator.code_valid?(guess) && @game.guess_count < MAX_ATTEMPTS
        mark = @game.mark_guess(guess)
        @guess_log << "#{guess}: #{mark}\n"
      end
      YamlUtils.save_sessions @sessions
      response.redirect('/')
    end
  end

  def hint
    return Rack::Response.new { |resp| resp.redirect('/') } unless (hint = @game.hint)
    Rack::Response.new do |response|
      response.set_cookie('secret_number', hint[0].to_s)
      response.set_cookie('secret_position', (hint[1] + 1).to_s)
      YamlUtils.save_sessions @sessions
      response.redirect('/')
    end
  end

  def save_result
    Rack::Response.new do |response|
      response.set_cookie('name', @request.params['name'])
      YamlUtils.save_result(@game, @request.params['name'])
      response.set_cookie('save_result', 'ok')
      response.redirect('/')
    end
  end

  def cancel_save_result
    Rack::Response.new do |response|
      response.set_cookie('save_result', 'cancel')
      response.redirect('/')
    end
  end

  def statistics
    Rack::Response.new(render('statistics.html.erb'))
  end
end
