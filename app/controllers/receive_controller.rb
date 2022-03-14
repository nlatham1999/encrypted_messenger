class ReceiveController < ApplicationController
    
    MONGODB_CONN_URL = "mongodb+srv://Admin:100Admin!@cluster0.ovcjj.mongodb.net/Cluster0?retryWrites=true&w=majority"

    def message

        # require 'mongo'
        
        # Mongo::Logger.logger.level = ::Logger::DEBUG
        # like debug but easier to read?
        Mongo::Logger.logger.level = ::Logger::FATAL 
        
        client = Mongo::Client.new(MONGODB_CONN_URL)

        db = client.database
        collection = db[:test]

        # doc = {"message": "is this working" }
        # result = collection.insert_one(doc)
        # @message = "Record inserted - id: #{result.inserted_id}"

        records = collection.find()

        records.each do |rec|
            rec.attributes.each do |k, v|
                next if k == '_id' # skip the _id field
                @message = @message + "#{k} #{v}"
            end
        end
          @message = "db test #{collection.find()}"
        client[:test].find.each { |doc| puts doc }
        client.close

        # @message = 'receiving message'
    end
end