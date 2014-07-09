module API
  class Echo < Grape::API

    format :json

    resource :echo do
      get '/' do
        {message: 'Hello, World!'}
      end
    end

  end
end