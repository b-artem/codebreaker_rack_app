# require 'erb'
require 'codebreaker_artem/game'
require 'codebreaker_artem/validator'
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
    @guess_log = []
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

  def guess_log
    guess_log = @request.cookies['guess_log'] || 'No guesses yet'
    guess_log.split("\n")
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
      response.set_cookie('guess_log', '')
      Utils.save_sessions @sessions
      response.redirect('/')
    end
  end

  def submit_guess
    Rack::Response.new do |response|
      find_game
      guess = @request.params['guess']
      return response.redirect('/') unless Validator.code_valid?(guess)
      mark = @game.mark_guess(guess)
      @guess_log = @request.cookies['guess_log']
      @guess_log ||= []
      @guess_log << "#{guess}: #{mark}\n"
      response.set_cookie('guess_log', @guess_log)
      Utils.save_sessions @sessions


      # return CLI.win(input, game.score) if Validator.win_mark?(mark)
      # return CLI.lose(game.secret_code, game.score, MAX) if game.guess_count >= MAX
      response.redirect('/')
    end
  end



  def find_game
    sid = @request.session['session_id']
    @game = @sessions[sid]
  end

  def save_game(sid, game)
    @sessions[sid] = game
  end
end
