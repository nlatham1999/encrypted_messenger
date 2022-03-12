class SendController < ApplicationController
    def message
        params.require(:message)

        message = params[:message]

        @message = 'sending message ' + message
    end
end