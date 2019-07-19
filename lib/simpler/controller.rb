require_relative 'view'

module Simpler
  class Controller

    attr_reader :name, :request, :response

    def initialize(env)
      @name = extract_name
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
    end

    def make_response(action)
      @request.env['simpler.controller'] = self
      @request.env['simpler.action'] = action

      send(action)
      write_response
      set_default_headers

      @response.finish
    end

    private

    def extract_name
      self.class.name.match('(?<name>.+)Controller')[:name].downcase
    end

    def set_default_headers
      @response['Content-Type'] = "text/#{ search_for_text_headers(@request.env['simpler.template']) || 'html' }"
    end

    def search_for_text_headers(template)
      return unless template.is_a?(Hash)
      template.keys.first.to_s
    end

    def write_response
      body = render_body

      @response.write(body)
    end

    def render_body
      View.new(@request.env).render(binding)
    end

    def params(key)
      # @request.params
      @request.env['simpler.router_params'][key]
    end

    def render(template)
      @request.env['simpler.template'] = template
    end

    def status(status_code)
      @response.status = status_code
    end

  end
end
