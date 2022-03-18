class SendController < ApplicationController
    MONGODB_CONN_URL = "mongodb+srv://Admin:100Admin!@cluster0.ovcjj.mongodb.net/Cluster0?retryWrites=true&w=majority"

    def message
        # verification
        params.require(:message)
        params.require(:writer)
        params.require(:key)
        params.require(:min)

        # get parameters
        message = params[:message]

        # connect to mongo
        Mongo::Logger.logger.level = ::Logger::FATAL 
        client = Mongo::Client.new(MONGODB_CONN_URL)

        # connect to collection
        db = client.database
        collection = db[:messages]

        # insert data
        doc = {"message": message }
        result = collection.insert_one(doc)

        # set status message
        @message = "Record inserted - id: #{result.inserted_id}"

    end
end