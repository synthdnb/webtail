module Webtail
  module App
    extend self

    def run
      ::Rack::Handler::WEBrick.run(
        Server.new,
        :Port          => Webtail.config[:port],
        :Logger        => ::WEBrick::Log.new("/dev/null"),
        :AccessLog     => [nil, nil],
        :StartCallback => proc { App.open_browser },
        :Host          => "0.0.0.0"
      )
    end

    def open_browser
      ::Launchy.open("http://#{Webtail.config[:host]}:#{Webtail.config[:port]}") rescue nil
    end

    class Server < ::Sinatra::Base
      set :webtailrc do
        path = File.expand_path(Webtail.config[:rc])
        File.exist?(path) && File.read(path)
      end

      set :hostname do
        Webtail.config[:host]
      end
      set :root, File.expand_path("../../../", __FILE__)

      get "/" do
        @web_socket_port = WebSocket.port
        @webtailrc = settings.webtailrc
        @hostname = settings.hostname
        erb :index
      end

      post "/" do
        Webtail.channel << params[:text]
      end
    end
  end
end
