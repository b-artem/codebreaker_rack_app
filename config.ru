require './lib/rackapp'
require './lib/middl'

app = Rack::Builder.new do
  use Rack::Reloader, 0
  use Rack::Static, urls: ['/stylesheets'], root: 'public'
  use Middl
  run RackApp
end

run app
