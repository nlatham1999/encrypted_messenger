include Errors

class ReceiveController < ApplicationController
    
    MONGODB_CONN_URL = ENV['MONGODB_URL']
    
    def message
        begin

            # verification
            params.require(:pass_phrase)
            params.require(:message_id)

            puts "got here"

            # get parameters
            message_id = params[:message_id]
            pass_phrase_and_salt = params[:pass_phrase]

            # split up salt and passphrase
            raise Errors::Passphrase unless pass_phrase_and_salt.length >= 16
            
            pass_phrase = pass_phrase_and_salt[0..-9]
            salt = pass_phrase_and_salt[-8..-1]

            # connect to mongo 
            Mongo::Logger.logger.level = ::Logger::FATAL 
            client = Mongo::Client.new(MONGODB_CONN_URL)

            # open up collection and query
            db = client.database
            collection = db[:messages]
            records = collection.find(:_id => BSON::ObjectId(message_id))

            raise Errors::NotFound unless records.count() == 1

            # get data
            message_found = ""
            records.each do |rec|
                message_found = rec[:message]
            end

            # decrypt message
            decoded = Base64.decode64 message_found.encode('ascii-8bit')

            decryptor = OpenSSL::Cipher.new 'aes-256-cbc'
            decryptor.decrypt
            decryptor.pkcs5_keyivgen pass_phrase, salt

            plain = decryptor.update decoded
            plain << decryptor.final

            @message = plain
            return

        # error handling
        rescue Errors::Passphrase
            e = Errors::Passphrase.new
        rescue Errors::NotFound
            e = Errors::NotFound.new
        # rescue => exception
        #     e = Errors::Internal.new
        end
        render json: ErrorSerializer.new(e), status: e.status

    end
end