class ResponseTimer
  TOKEN= "%RESPONSE_TIME%"

  def initialize(app)
    @app= app
  end

  def call(env)
    start= Time.now
    status, headers, response = @app.call(env)
    stop= Time.now

    content_type= headers['Content-Type']
    if content_type and content_type.include? 'text/html'

      # Insert time
      time_ms= (stop - start) * 1000
      replacement= "#{time_ms.round 1} ms"
      new_response= []
      response.each{|s| new_response<< s.sub(TOKEN, replacement)}

      # Create new response
      rr= Rack::Response.new(new_response, status, headers)
      rr.finish
      status, headers, response = rr.to_a
    end

    [status, headers, response]
  end
end