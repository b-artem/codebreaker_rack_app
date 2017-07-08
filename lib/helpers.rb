module Helpers
  def guess_left
    return MAX_ATTEMPTS unless @game
    MAX_ATTEMPTS - @game.guess_count
  end

  def guess_count
    return '1' unless @game
    guess_count = @game.guess_count
    return guess_count if guess_count == MAX_ATTEMPTS
    guess_count + 1
  end

  def guess_log
    guess_log = @guess_log || 'No guesses yet'
    guess_log.split("\n")
  end

  def hints_left
    return 'no' unless @request.cookies['secret_number']
    return 'no' unless @request.cookies['secret_number'] == ''
    '1'
  end

  def show_hint?
    return unless (hint = @request.cookies['secret_number'])
    return if hint == ''
    true
  end

  def propose_to_save_result?
    true if @request.cookies['save_result'] == ''
  end

  def stats
    YamlUtils.read_stats
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
    return if @game.guess_count < MAX_ATTEMPTS
    true
  end
end
