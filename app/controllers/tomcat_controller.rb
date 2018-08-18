require 'line/bot'

class TomcatController < ApplicationController
protect_from_forgery with: :null_session

    #Main Structure
    def webhook

        # line signature
        body = request.body.read
        signature = request.env['HTTP_X_LINE_SIGNATURE']
        unless line.validate_signature(body, signature)
            render plain: 'Bad Request', status: 400
            return
        end


        #Record Channel
        # Channel.find_or_create_by(channel_id: channel_id)

        if received_text[0..1] == '功能'
            reply_text = '學說話, 推齊, 食咩'
        elsif received_text[0..2] == '食咩;'

        #Chosing
        reply_text = chose(received_text)

        else

        #Learn Speaking
        reply_text = learn(channel_id, received_text)

        #Keyword Reply
        reply_text = keyword_reply(channel_id, received_text) if reply_text.nil?

        #Push
        reply_text = echo2(channel_id, received_text) if reply_text.nil?

        #Record conversation 
        save_to_received(channel_id, received_text)
        save_to_reply(channel_id, reply_text)
        
        end

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
    def learn (channel_id, received_text)
        return nil unless received_text[0..4] == '喵學說話;'

        received_text = received_text[5..-1]
        semicolon_index = received_text.index(';')

        #If ';' not found
        return nil if semicolon_index.nil?

        keyword = received_text[0..semicolon_index-1]
        message = received_text[semicolon_index+1..-1]

        KeywordMapping.create(channel_id: channel_id, keyword: keyword, message: message)
        '喵~'
    end

    #Chosing
    def chose (received_text)
        text = received_text[3..-1]
        items = []
        items = text.split(" ")
        food = items.sample
        return "#{food} 喵~"
    end

    #Keyword Reply
    def keyword_reply(channel_id, received_text)
        message = KeywordMapping.where(channel_id: channel_id, keyword: received_text).last&.message
        return message unless message.nil?
        KeywordMapping.where(keyword: received_text).last&.message
    end

    #Channel ID
    def channel_id
        source = params['events'][0]['source']
        source['groupId'] || source['roomId'] || source['userId']
    end

    #Save To Received
    def save_to_received(channel_id, received_text)
        return if received_text.nil?
        Received.create(channel_id: channel_id, text: received_text)
    end

    #Save To Reply
    def save_to_reply(channel_id, reply_text)
        return if reply_text.nil?
        Reply.create(channel_id: channel_id, text: reply_text)
    end

    #Push
    def echo2(channel_id, received_text)
        recent_received_texts = Received.where(channel_id: channel_id).last(5)&.pluck(:text)
        return nil unless received_text.in? recent_received_texts

        last_reply_text = Reply.where(channel_id: channel_id).last&.text
        return nil if last_reply_text == received_text

        received_text
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
