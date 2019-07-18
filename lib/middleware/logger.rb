require 'logger'

class AppLogger

  def initialize(app, **options)
    @logger = Logger.new(options[:logdev] || STDOUT)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    generate_log(status, headers, env)
    [status, headers, body]
  end

  def generate_log(status, headers, env)
    @logger.info "#{ env }"

    @logger.info "Request: #{env['REQUEST_METHOD']} #{env['REQUEST_PATH']}"
    @logger.info "Handler: #{env['simpler.controller'].class.name}##{env['simpler.action']}"
    @logger.info "Parameters: #{env['QUERY_STRING']}"
    @logger.info "Response: #{status} #{headers['Contetnt-Type']} #{env['simpler.template']}"
  end
end
