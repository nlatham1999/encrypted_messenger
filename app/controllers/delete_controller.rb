# empties the collections
class DeleteController < ApplicationController
    
    MONGODB_CONN_URL = ENV['MONGODB_URL']

    def collections
        Mongo::Logger.logger.level = ::Logger::FATAL 
        client = Mongo::Client.new(MONGODB_CONN_URL)

        # connect to collection
        db = client.database
        messages_collection = db[:messages]

        users_collection = db[:users]

        messages_collection.delete_many({})

        users_collection.delete_many({})

        @message = "removed everything"
    end
end