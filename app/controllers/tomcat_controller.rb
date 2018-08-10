require 'line/bot'

class TomcatController < ApplicationController
protect_from_forgery with: :null_session

    #Main Structure
    def webhook
        #Learn Speaking
        reply_text = learn(received_text)

        #Keyword Reply
        reply_text = keyword_reply(received_text) if reply_text.nil?
        
        #Send Message to Line
        response = reply_to_line(reply_text)
        
        #response 200
        head :ok
    end

    #Received Text From User
    def received_text
        message = params['events'][0]['message']
        if message.nil?
            nil
        else
            message['text']
        end
    end

    #Learn Speaking
    def learn (received_text)
        return nil unless received_text[0..4] == '喵學說話;'

        received_text = received_text[5..-1]
        semicolon_index = received_text.index(';')

        #If ';' not found
        return nil if semicolon_index.nil?

        keyword = received_text[0..semicolon_index-1]
        message = received_text[semicolon_index+1..-1]

        KeywordMapping.create(keyword: keyword, message: message)
        '喵~'
    end

    #Keyword Reply
    def keyword_reply(received_text)
        mapping = KeywordMapping.where(keyword: received_text).last
        if mapping.nil?
            nil
        else
            mapping.message
        end        
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

    #Line Bot API Initialization
    def line
        @line ||= Line::Bot::Client.new {
            |config|
            config.channel_secret = '168b8406f6a932635df7f567e407929c'
            config.channel_token = 'fUXC56EsDT0OXh9rxhPbSxwq3Ap+pKaJgDFuO8FIrx2G7GK40glmBiqzGGALnz+kkNvFyqheKfBoeMl2BCsiHRT48zFJY1pTnuW2KuaPZsWbKBbnqMXncdGvB+hoWOdPloQRA5/4CMUgh47uPZyD4wdB04t89/1O/w1cDnyilFU='
        }
    end
    
end
