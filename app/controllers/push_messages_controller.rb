require 'line/bot'

class PushMessagesController < ApplicationController
    before_action :authenticate_user!

    #GET /push_messages/new
    def new 
    end

    #POST /push_messages
    def create
        text = params[:text]
        Channel.all.each do |channel|
            push_to_line(channel.channel_id, text)
        end
        redirect_to '/push_messages/new'
    end

    #Send message to line
    def push_to_line(channel_id, text)
        return nil if channel_id.nil? or text.nil?

        #Set reply message
        message = {
            type: 'text',
            text: text
        }

        #Send message
        line.push_message(channel_id, message)
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