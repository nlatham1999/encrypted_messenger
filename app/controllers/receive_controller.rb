class ReceiveController < ApplicationController
    
    MONGODB_CONN_URL = "mongodb+srv://Admin:100Admin!@cluster0.ovcjj.mongodb.net/Cluster0?retryWrites=true&w=majority"

    def message

        # connect to mongo 
        Mongo::Logger.logger.level = ::Logger::FATAL 
        client = Mongo::Client.new(MONGODB_CONN_URL)

        # open up collection and query
        db = client.database
        collection = db[:messages]
        records = collection.find()

        # get data
        @message = ""
        records.each do |rec|
            @message += rec[:message]
        end

        # close
        client.close

    end
end