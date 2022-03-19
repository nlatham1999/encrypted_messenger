class ReceiveController < ApplicationController
    
    MONGODB_CONN_URL = "mongodb+srv://Admin:100Admin!@cluster0.ovcjj.mongodb.net/Cluster0?retryWrites=true&w=majority"

    def message

        # verification
        params.require(:pass_phrase)
        params.require(:salt)
        params.require(:message_id)

        # get parameters
        pass_phrase = params[:pass_phrase]
        salt = params[:salt]
        message_id = params[:message_id]

        # connect to mongo 
        Mongo::Logger.logger.level = ::Logger::FATAL 
        client = Mongo::Client.new(MONGODB_CONN_URL)

        # open up collection and query
        db = client.database
        collection = db[:messages]
        records = collection.find(:_id => BSON::ObjectId(message_id))

        # get data
        message_found = ""
        records.each do |rec|
            message_found = rec[:message]
        end

        puts message_found

        # decrypt message
        decoded = Base64.decode64 message_found.encode('ascii-8bit')

        decryptor = OpenSSL::Cipher.new 'aes-256-cbc'
        decryptor.decrypt
        decryptor.pkcs5_keyivgen pass_phrase, salt

        plain = decryptor.update decoded
        plain << decryptor.final

        @message = plain

        # close
        client.close

    end
end