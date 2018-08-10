class TomcatController < ApplicationController
protect_from_forgery with: :null_session

    def webhook
        render plain: params
    end

    def sent_request
        uri - URI('http://localhost:3000/tomcat/rb')
        response = Net::HTTP.get(uri)
        render plain: response
end
