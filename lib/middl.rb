class Middl
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    # headers['X-Custom-Header'] = "customheader.v1"
    [status, headers, body]
  end
end
