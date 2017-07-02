require 'codebreaker_artem/game'
require 'codebreaker_artem/validator'
require 'yaml'
require './lib/yaml_utils'

MAX_ATTEMPTS = CodebreakerArtem::Game::MAX_GUESS_NUMBER

class RackApp
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
    else Rack::Response.new('Not found', 404)
    end
  end

  private

  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end


  ###############################################################
  def game
    sid = @request.session['session_id']
    game = @sessions[sid][:game]
    game.inspect.tr('#<>::@', '') || 'No game yet'
  end
  ################################################################

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

  def guess_count
    return '1' unless @game
    guess_count = @game.guess_count
    return guess_count if guess_count == MAX_ATTEMPTS
    guess_count + 1
  end

  def guess_left
    return MAX_ATTEMPTS unless @game
    MAX_ATTEMPTS - @game.guess_count
  end

  def guess_log
    guess_log = @guess_log || 'No guesses yet'
    guess_log.split("\n")
  end

  def hint
    return Rack::Response.new { |resp| resp.redirect('/') } unless hint = @game.hint
    Rack::Response.new do |response|
      response.set_cookie('secret_number', hint[0].to_s)
      response.set_cookie('secret_position', (hint[1] + 1).to_s)
      YamlUtils.save_sessions @sessions
      response.redirect('/')
    end
  end

  def hints_left
    return 'no' unless @request.cookies['secret_number']
    return 'no' unless @request.cookies['secret_number'] == ''
    '1'
  end

  def show_hint?
    return unless hint = @request.cookies['secret_number']
    return if hint == ''
    true
  end

  def secret_number
    @request.cookies['secret_number']
  end

  def secret_position
    @request.cookies['secret_position']
  end

  def won?
    return unless @guess_log
    return unless @guess_log.include? '++++'
    true
  end

  def lost?
    return if won?
    return unless @game
    return if @game.guess_count < CodebreakerArtem::Game::MAX_GUESS_NUMBER
    true
  end
end
