require './lib/rackapp'
# require './lib/middl'

app = Rack::Builder.new do
  use Rack::Reloader, 0
  use Rack::Static, urls: ['/stylesheets'], root: 'public'
  use Rack::Session::Cookie, key: 'rack.session',
                             expire_after: 2_592_000,
                             secret: ENV['SECRET_KEY']
  run RackApp
end

run app
