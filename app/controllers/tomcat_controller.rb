require 'line/bot'

class TomcatController < ApplicationController
protect_from_forgery with: :null_session
    
    #Line Bot API Initialization
    def line
        @line ||= Line::Bot::Client.new {
            |config|
            config.channel_secret = '168b8406f6a932635df7f567e407929c'
            config.channel_token = 'fUXC56EsDT0OXh9rxhPbSxwq3Ap+pKaJgDFuO8FIrx2G7GK40glmBiqzGGALnz+kkNvFyqheKfBoeMl2BCsiHRT48zFJY1pTnuW2KuaPZsWbKBbnqMXncdGvB+hoWOdPloQRA5/4CMUgh47uPZyD4wdB04t89/1O/w1cDnyilFU='
        }
    end

    def webhook
        #The reply text setting
        reply_text = keyword_reply(received_text)
        
        #Send message
        response = reply_to_line(reply_text)
        
        #response 200
        head :ok
    end
    
    def received_text
        message = params['events'][0]['message']
        if message.nil?
            nil
        else
            message['text']
        end
    end

    def keyword_reply(received_text)
        #Learning Record
        keyword_mapping = {
            'QQ' => 'Sad for you',
            'I am sad' => '... Okay'
        }

        #Check list
        keyword_mapping[received_text]
    end
    
    #Send message to line
    def reply_to_line(reply_text)
        return nil if reply_text.nil?

        #Get reply token
        reply_token = params['events'][0]['replyToken'] 
        
        #Set reply message
        message = {
            type: 'text',
            text: reply_text
        }

        #Send message
        line.reply_message(reply_token, message)
    end

end
