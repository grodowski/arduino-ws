module API
  class Publisher < Grape::API

    format :json

    resource :pub do
      get '/' do
        Redis.new.publish 'test-channel', {message: 'Hello, World!'}.to_json
        {status: 'published!'}
      end
    end

  end
end