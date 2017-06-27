class Middl
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    ses = env['rack.session']

    request = Rack::Request.new(env)

  # other uses of request without needing to know what keys of env you need


    binding.pry
    # headers['X-Custom-Header'] = "customheader.v1"
    [status, headers, body]
  end
end
