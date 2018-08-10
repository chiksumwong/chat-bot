require 'line/bot'

class TomcatController < ApplicationController
protect_from_forgery with: :null_session

    def eat
        render plain: "Eat What ?"
    end

    def webhook
        #Line Bot API
        client = Line::Bot::Client.new {
            |config|
            config.channel_secret = '168b8406f6a932635df7f567e407929c'
            config.channel_token = 'fUXC56EsDT0OXh9rxhPbSxwq3Ap+pKaJgDFuO8FIrx2G7GK40glmBiqzGGALnz+kkNvFyqheKfBoeMl2BCsiHRT48zFJY1pTnuW2KuaPZsWbKBbnqMXncdGvB+hoWOdPloQRA5/4CMUgh47uPZyD4wdB04t89/1O/w1cDnyilFU='
        }

        #Get reply token
        reply_token = params['events'][0]['replyToken']

        #Set reply message
        message = {
            type: 'text',
            text: '喵~'
        }

        #Sent message
        response = client.reply_message(reply_token, message)

        #respons 200
        head :ok
    end

    def sent_request
        uri - URI('http://localhost:3000/tomcat/rb')
        response = Net::HTTP.get(uri)
        render plain: response
    end
end
