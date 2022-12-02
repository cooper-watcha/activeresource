module ActiveResource
  module TestHelper
    class CaptureConnection < Connection
      def request(method, path, *arguments)
        ActiveSupport::Notifications.instrument("request.active_resource") do |payload|
          payload[:method]      = method
          payload[:request_uri] = "#{site.scheme}://#{site.host}:#{site.port}#{path}"
          payload[:connection]  = http
          payload[:method] = method
          payload[:path] = path
          payload[:arguments] = arguments
          payload[:action] = Rails.application.routes.recognize_path(path, method: method)[:action]
        end
        []
      end
    end

    module Methods
      def request_controller(payload)
        uri = URI.parse(payload[:request_uri])
        send(payload[:method], payload[:action], params: Rack::Utils.parse_nested_query(uri.query))
      end
    end
  end
end