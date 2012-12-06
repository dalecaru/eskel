module Rack
  module Eskel
    module Middleware
      
      class TryStatic
        ALLOWED_VERBS = %w[GET HEAD]

        def initialize(app, options)
          @app = app
          @try = ['', *options.delete(:try)]
          @static = ::Rack::Static.new(lambda { [404, {}, []] }, options)
        end

        def call(env)
          if ALLOWED_VERBS.include? env["REQUEST_METHOD"]
            orig_path = env['PATH_INFO']
            found = nil
            @try.each do |path|
              resp = @static.call(env.merge!({'PATH_INFO' => orig_path + path}))
              break if 404 != resp[0] && found = resp
            end
            found or @app.call(env.merge!('PATH_INFO' => orig_path))
          else
            @app.call(env)
          end
        end
      end
    end
  end
end