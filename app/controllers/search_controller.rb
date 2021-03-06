include Errors

class SearchController < ApplicationController
    
    MONGODB_CONN_URL = ENV['MONGODB_URL']
    
    def messages
        begin
            # verification
            params.require(:username)

            # get the parameters
            username = params[:username]

            message_type = ""
            if params[:message_type].present?
                message_type = params[:message_type]
            end
            
            # connect to mongo
            Mongo::Logger.logger.level = ::Logger::FATAL 
            client = Mongo::Client.new(MONGODB_CONN_URL)

            # connect to collection
            db = client.database
            collection = db[:messages]

            if message_type == ""
                records = collection.find(:username => username)
            else
                records = collection.find({:username => username, :message_type => message_type})
            end

            ids = []
            records.each do |rec|
                ids.append(rec[:_id].to_s)
            end

            @message = {"status" => 200, "ids": ids}
            return
        rescue => exception
            e = Errors::Internal.new
        end
        render json: ErrorSerializer.new(e), status: e.status
    end
end