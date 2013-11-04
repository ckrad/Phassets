#\ -p 3210 -E development
$:.unshift File.expand_path("../lib", __FILE__)

require 'bundler/setup'
Bundler.require
require 'json'
require 'phassets'

ph = Phassets::App.new(File.dirname(__FILE__))

map "/" do
  run lambda { |env|
    [
      200, 
      {
        'Content-Type'  => 'text/html', 
        'Cache-Control' => 'public, max-age=86400' 
      },
      ["index"]
    ]
  }
end

map "/#{ph.assets_url}" do
  run ph.sprockets
end

map "/#{ph.assets_url}/images" do
  run ph.sprockets
end

map "/files" do
  run lambda { |env|

    files   = []
    request = env['PATH_INFO'].strip.chomp('/').reverse.chomp('/').reverse

    unless request.empty?
      request.split('/').each do |file|
        ph.sprockets.find_asset(file).to_a.each do |path|
          files << {
            path: ph.sprockets.attributes_for(path.pathname).logical_path,
            digest: path.digest
          }
        end
      end
    end

    [
      200,
      {
        'Content-Type'  => 'application/json', 
        'Cache-Control' => 'no-cache, must-revalidate' 
      },
      [files.to_json]
    ]
  }
end