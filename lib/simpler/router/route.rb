module Simpler
  class Router
    class Route

      attr_reader :controller, :action

      def initialize(method, path, controller, action)
        @method = method
        @path = path
        @path_pattern = @path.split("/").freeze
        @controller = controller
        @action = action
      end

      def match?(method, incoming_path)
        @method == method && incoming_path.match(@path)
      end

      def path_parse(env)
        method = env['REQUEST_METHOD'].downcase.to_sym
        path = env['PATH_INFO']

        incoming_path = path.split("/")
        path_pattern = @path_pattern

        if @method == method
          if path_pattern == incoming_path
            true
          else
            params_hash = Hash[(@path_pattern - incoming_path).zip(incoming_path - @path_pattern)]
            if path_pattern.each { |elem| elem.replace(params_hash[elem]) if params_hash[elem] } == incoming_path
              env['simpler.router_params'] = params_hash
              true
            end
          end
        end
      end

    end
  end
end
